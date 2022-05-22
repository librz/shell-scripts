#!/bin/bash

# linux init script, run this to set up 
# OS support: Ubuntu, macOS 
# usage: bash <(curl -sL https://realrz.com/shell-scripts/init.sh)

# this script is idempotent, in another word, running it multiple times has the same effect as running it once
# so when this script is updated, just execute it again


# remote repo address 
repoAddr="https://realrz.com/shell-scripts"

# utils functions

function err() {
	echo "$1" >&2
}

function header() {
	echo -e "\n** $1 **\n"
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
header "Checking distro"
if ! distro=$(getDistro); then
	exit 1
fi
echo "You are running: $distro"

# auto remove
header "Removing unnecessary pacakges using apt autoremove"
yes | apt autoremove

# install softwares
header "Installing packages"
if [[ "$distro" == "Ubuntu" ]]; then
	if apt update &>/dev/null && yes | apt install zsh vim git snapd curl tldr tree xxd net-tools sysstat nmap dnsutils; then
		echo "success"
	else
		err "apt install failed"
		exit 2
	fi
else
	# macOS
	echo "please use homebrew to manually install softwares on macOS"
fi

# language-pack-zh-hans is only aviailable in ubuntu 
if [[ "$distro" = "Ubuntu" ]]; then
	header "Installing language-pack-zh-hans"
	# also install language-pack-zh-hans
	yes | apt install language-pack-zh-hans && echo "success"
fi

# add zsh to /etc/shells if it's not there
if ! grep -q zsh /etc/shells; then
	command -v zsh >> /etc/shells
fi

# change login shell to zsh
header "Changing Login Shell to zsh"
if chsh -s "$(command -v zsh)"; then
	echo "success"
else
	err "failed to change login shell to zsh"
	exit 3
fi

header "Setting Timezone to Asia/Shanghai"
if ! diff /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; then
	cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "success"
fi

header "Installing vim-plug"
curl -sfLo ~/.vim/autoload/plug.vim --create-dirs "$repoAddr"/plug.vim
echo "success"

header "Configuring .vimrc, .gitconfig & .zshrc"
curl -sL "$repoAddr"/.vimrc > ~/.vimrc
curl -sL "$repoAddr"/.zshrc > ~/.zshrc
curl -sL "$repoAddr"/.gitconfig > ~/.gitconfig
echo "success"

if [[ "$distro" != "macOS" ]]; then
	if [[ -f /etc/ssh/sshd_config ]]; then
		header 'File /etc/ssh/sshd_config exits, chaning sshd port from 22 to 9000'
		# change sshd port to 9000, set ClientAliveInterval to 5 seconds
		# different ISO providers may have different sshd_config, so this may not work
		sed -i 's/#Port 22/Port 9000/g' /etc/ssh/sshd_config
		sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 5/g' /etc/ssh/sshd_config
		service sshd restart
		echo 'success'
	fi
fi

header "Sourcing .zshrc" 
# shellcheck source=/dev/null
source ~/.zshrc
echo "sourced"

header "Success: System is all set"
header "Note: Some changes may require re-login to be effective"
