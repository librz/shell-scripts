#!/bin/bash

# 3p: program, process, port

# usage:
# bash <(curl -sL https://raw.githubusercontent.com/librz/shell_scripts/main/3p.sh) --program nginx
# bash <(curl -sL https://raw.githubusercontent.com/librz/shell_scripts/main/3p.sh) --pid 1234
# bash <(curl -sL https://raw.githubusercontent.com/librz/shell_scripts/main/3p.sh) --port 80

# check distro
distro=$(head -1 /etc/os-release | cut -d'"' -f2)
if [[ $distro != "Ubuntu" ]]; then
	echo "sorry, this script only supports Ubuntu"
	exit 1 
fi

# check if awk & netstat is installed
if ! (command -v awk netstat &> /dev/null); then
	echo "to run this script, awk & netstat are required"
	echo "Install them right now?(Y/n)"
	read -r answer
	if [[ $answer = "Y" || $answer = "y" ]]; then
		apt install awk net-tools
	else
		exit 2
	fi
fi

# find port(s) by pid, 1 process can listen on many ports
function printPortsByPid {
	ports=$(netstat -tulpn | awk -v pattern="^$1" '(NR>2 && $7 ~ pattern){print $4}' | awk -F':' '{print $NF}' | sort -n | uniq | tr '\n' ' ')
	echo "$ports"
}

if [[ "$#" -ne 2 ]]; then
	echo "wrong usage"
	exit 3;
elif [[ "$1" = "--port" ]]; then
	port="$2"
	segment=$(netstat -tulpn | awk -v pattern=":$port$" '(NR>2 && $4 ~ pattern){print $7}')
	if [[ -z "$segment" ]]; then
		echo "no process is listening on port $port"
		exit 4
	fi
	# if port is valid, there must be 1 and only 1 process and program listening to it
	# find program
	program=$(echo "$segment" | awk -F'[/:]' '{print $2}' | sort | uniq)
	# find pid
	pid=$(echo "$segment" | awk -F'[/:]' '{print $1}' | sort | uniq)
	# format & output
	echo "program:$program pid:$pid port:$port"
elif [[ "$1" = "--pid" ]]; then
	pid="$2"
	# find program
	program=$(ps aux | awk -v pid="$pid" '($2==pid){print $11}' | cut -d':' -f1 | awk -F'/' '{print $NF}' )
	if [[ -z "$program" ]]; then
	 	echo "$pid is not valid process id"
		exit 5
	fi	
	# find port(s), 1 process can listen on many ports
	port=$(printPortsByPid "$pid")
	# format & output
	if [[ -z "$port" ]]; then
		echo "program:$program pid:$pid port:none"
	else
		echo "program:$program pid:$pid port:$port"
	fi
elif [[ "$1" = "--program" ]]; then 
	program="$2"
	# test if program exits
	if ! (command -v "$program" &>/dev/null); then
		echo "$program doesn't exist"
		exit 6
	fi
	# find pid(s), a program can have many process
	# pid=$(pgrep "$program"), I don't like pgrep's way of matching
	# what i need is exact match
	pid=$(ps aux | awk '{print $2, $11}' | tr -d ':' | awk -v pattern="$program$" '($NF ~ pattern){print $1}')
	if [[ -z "$pid" ]]; then
		echo "$program doesn't have any running process"
		exit 7
	fi
	# for each pid, find port
	while IFS= read -r line
	do
		port=$(printPortsByPid "$line")
		if [[ -z "$port" ]]; then
			port="none"
		fi
		echo "program:$program pid:$line port:$port"
	done <<< "$pid"
else
	echo "wrong option"
	exit 8;
fi
