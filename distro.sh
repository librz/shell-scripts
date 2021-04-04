#!/bin/bash

# get distro
# supported distros: Debian, Ubuntu, macOS, Windows(mingw & cygwin)
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
	fi
elif [[ $(uname) == "Darwin" ]]; then
	# god knows why Apple names its desktop system macOS starting with a lower case letter
	distro="macOS"
elif uname | grep -Eiq 'mingw|cygwin'; then
	# git bash uses mingw underneath the hood
	distro="Windows"
else
	echo "Sorry, this script only support Debian/Ubuntu, macOS & Windows"
	exit 1
fi

echo "$distro"
