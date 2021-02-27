#!/bin/bash

# printd => print dsitro
# usage: bash <(curl -sL http://realrz.com/scripts/printd.sh)

# supported distros: Debian, Ubuntu, macOS, FreeBSD

distro=""
if [[ -e /etc/os-release ]]; then
	# Linux has /etc/os-release file
	# shellcheck disable=SC1091
	source /etc/os-release
	# /etc/os-release when sourced, will add the $NAME environment variable
	if echo "$NAME" | grep -i debian &>/dev/null; then
		distro="Debian"
	elif echo "$NAME" | grep -i ubuntu &>/dev/null; then
		distro="Ubuntu"
	fi
elif [[ $(uname) == "Darwin" ]]; then
	# god knows why Apple names its desktop system macOS starting with a lower case letter
	distro="macOS"
elif [[ $(uname) == "FreeBSD" ]]; then
	distro="FreeBSD"
else
	err "Sorry, this script only support Debian/Ubuntu, FreeBSD/macOS"
	exit 1
fi

echo "$distro"