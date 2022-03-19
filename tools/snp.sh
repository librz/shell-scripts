#!/bin/bash

# snp => show non-printable 
# aim: explicitly show common non-printable characters in their escaped form
# distro support: Ubuntu, macOS
# usage: bash <(curl -sL http://realrz.com/shell-scripts/snp.sh) /path/to/file

# supported mappings
# 1. carriage return => \r
# 2. newline (line feed) => \n
# 3. tab => \t
# 4. space => \x20

# options 
# by default, all the mappings are included, you can specify those mappings using options:
# -r: carriage return
# -n: newline (line feed)
# -t: tab
# -s: space
# options can be combined, e.g.
# bash <(curl -sL http://realrz.com/shell-scripts/snp.sh) -rn /path/to/file

# util functions

function err() {
	echo "$1" >&2
}

function getDistro() {
	local distro
	if [[ -e /etc/os-release ]]; then
		# Linux has /etc/os-release file
		# shellcheck disable=SC1091
		source /etc/os-release
		# /etc/os-release when sourced, will add the $NAME environment variable
		if echo "$NAME" | grep -iq ubuntu; then
			distro="Ubuntu"
		fi
	elif [[ $(uname) == "Darwin" ]]; then
		distro="macOS"
	else
		echo "Sorry, this script only support Ubuntu & macOS"
		exit 1
	fi
	echo "$distro"
}

# check distro
if ! distro=$(getDistro); then
	exit 1
fi

# check if xxd is installed
if ! command -v xxd &>/dev/null; then
	if [[ "$distro" == "debian" || "$distro" == "ubuntu" ]]; then
		yes | apt install xxd &> /dev/null  
	else
		err "this script requires xxd to run"
		err "try install xxd first, then run this script again" 
		exit 1
	fi
fi

# character       UTF-8 hex    Printable
# line feed       0a           no
# carriage return 0d           no
# tab             09           no
# space           20           no
# \               5c           yes
# n               6e           yes
# r               72           yes
# t               74           yes
# x               78           yes
# 2               32           yes
# 0               30           yes

# main program starts here
xxd -c 1 "$1" \
| awk '{print $2}' \
| sed 's/0a/5c6e/g' \
| sed 's/0d/5c72/g' \
| sed 's/09/5c74/g' \
| sed 's/20/5c783230/g' \
| tr -d '\n' \
| xxd -r -p
# use echo to add newline to the end
echo
