#!/bin/bash

# get distro
# supported distros: Ubuntu, macOS
# output: distro name

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

