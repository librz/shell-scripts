#!/bin/bash

# 3p: program, pid, port

# usage:
# bash <(curl -sL http://realrz.com/scripts/3p.sh) --program nginx
# bash <(curl -sL http://realrz.com/scripts/3p.sh) --pid 1234
# bash <(curl -sL http://realrz.com/scripts/3p.sh) --port 80

: '
output format example, each line except the frist line represents a process
Program    Pid        Port
nginx      87236      80,443              
nginx      358789     none 
'

function err {
	echo "$1" >&2
}

# check distro
if [[ -e /etc/os-release ]]; then
	# shellcheck disable=SC1091
	source /etc/os-release
	if [[ "$NAME" != "Ubuntu" && "$NAME" != "Debian" ]]; then
		err "sorry, this script only supports Ubuntu/Debian"
		exit 1 
	fi
else
	err "sorry, this script only supports Ubuntu"
	exit 1 
fi

# check if awk & netstat is installed, if not, install them
if ! (command -v awk netstat &> /dev/null); then
	apt update
	yes | apt install awk net-tools &> /dev/null
fi

# find port(s) by pid, 1 process can listen on many ports
function printPortsByPid {
	ports=$(
		netstat -tulpn \
		| awk -v pattern="^$1" '(NR>2 && $7 ~ pattern){print $4}' \
		| awk -F':' '{print $NF}' \
		| sort -n \
		| uniq \
		| tr '\n' ',' \
		| sed 's/,$//'
	)
	echo "$ports"
}

# format output
function printResultHeader {
	printf "%-15s %-10s %-20s\n" "Program" "Pid" "Port"
}
function printResultBody {
	local program="$1"
	local pid="$2"
	local port="$3"
	if [[ -z "$port" ]]; then
		port="none"
	fi
	printf "%-15s %-10d %-20s\n" "$program" "$pid" "$port"
}

# main program starts here
if [[ "$#" -ne 2 ]]; then
	err "wrong usage"
	exit 3;
elif [[ "$1" = "--port" ]]; then
	port="$2"
	segment=$(netstat -tulpn | awk -v pattern=":$port$" '(NR>2 && $4 ~ pattern){print $7}')
	if [[ -z "$segment" ]]; then
		err "no process is listening on port $port"
		exit 4
	fi
	# if port is valid, there must be 1 and only 1 process and program listening to it
	# find program
	program=$(echo "$segment" | awk -F'[/:]' '{print $2}' | sort | uniq)
	# find pid
	pid=$(echo "$segment" | awk -F'[/:]' '{print $1}' | sort | uniq)
	# format & output
	printResultHeader
	printResultBody "$program" "$pid" "$port"
elif [[ "$1" = "--pid" ]]; then
	pid="$2"
	# find program
	program=$(
		ps aux \
		| awk -v pid="$pid" '($2==pid){print $11}' \
		| cut -d':' -f1 \
		| awk -F'/' '{print $NF}'
	)
	if [[ -z "$program" ]]; then
	 	err "no running process has pid $pid"
		exit 5
	fi	
	# find port(s), 1 process can listen on many ports
	port=$(printPortsByPid "$pid")
	# format & output
	printResultHeader
	printResultBody "$program" "$pid" "$port"
elif [[ "$1" = "--program" ]]; then 
	program="$2"
	# test if program exits
	if ! (command -v "$program" &>/dev/null); then
		err "$program doesn't exist"
		exit 6
	fi
	# find pid(s), a program can have many process
	# pgrep -x flag means exact match
	pid=$(pgrep -x "$program")
	if [[ -z "$pid" ]]; then
		err "$program doesn't have any running process"
		exit 7
	fi
	printResultHeader
	# for each pid, find port
	while IFS= read -r line
	do
		port=$(printPortsByPid "$line")
		printResultBody "$program" "$line" "$port"
	done <<< "$pid"
else
	err "wrong option"
	exit 8;
fi
