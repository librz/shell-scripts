#!/bin/bash

# get distro
# supported distros: Debian, Ubuntu, Kali, macOS
# usage: bash <(curl -sL http://realrz.com/shell-scripts/distro.sh)

distro=""

if [[ -e /etc/os-release ]]; then
	# Linux has /etc/os-release file
	# shellcheck disable=SC1091
	source /etc/os-release
	# /etc/os-release when sourced, will add the $NAME environment variable
	if echo "$NAME" | grep -iq debian; then
		distro="Debian"
	elif echo "$NAME" | grep -iq ubuntu; then
		distro="Ubuntu"
	else echo "$NAME" | grep -iq kali; then
		distro="Kali"
	fi
elif [[ $(uname) == "Darwin" ]]; then
	distro="macOS"
else
	echo "Sorry, this script only support Debian/Ubuntu & macOS"
	exit 1
fi

echo "$distro"
