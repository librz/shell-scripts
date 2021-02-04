#!/bin/bash

# run this script whenever setting up a new machine
# it supports Debian/Ubuntu, MacOS & FreeBSD
# usage: bash <(curl -sL https://raw.githubusercontent.com/librz/shell_scripts/main/init.sh)

function err {
	echo "$1" >&2
}

# check distro
distro=""
if [[ -e /etc/os-release ]]; then
	# Linux has /etc/os-release file
	source /etc/os-release
	if echo "$NAME" | grep -i debian &>/dev/null; then
		distro="Debian"
	elif echo "$NAME" | grep -i ubuntu &>/dev/null; then
		distro="Ubuntu"
	fi
elif [[ $(uname) == "Darwin" ]]; then
	distro="MacOS"
elif [[ $(name) == "FreeBSD" ]]; then
	distro="FreeBSD"
else
	err "Sorry, this script only support Debian/Ubuntu, FreeBSD/MacOS"
	exit 1
fi

echo "You are running: $distro"

# install common softwares
if [[ "$distro" == "FreeBSD" ]]; then
	pkg update
	# tldr, net-tools, dnsutils are not aviailable in freebsd
	if yes | pkg install zsh vim git curl tree nmap xxd; then
		echo "pkg instal succeeded"
	else
		err "pkg install failed, aborted"
		exit 2
	fi
elif apt update && yes | apt install zsh vim git snapd curl tldr tree xxd net-tools nmap dnsutils; then
	echo "apt install succeeded"
else 
	err "apt install failed, aborted"
	exit 2
fi

# language-pack-zh-hans is only aviailable in ubuntu 
if [[ "$distro" = "Ubuntu" ]]; then
	# also install language-pack-zh-hans
	yes | apt install language-pack-zh-hans
fi

# ass zsh to /etc/shells if it's not there
if ! (grep zsh /etc/shells &>/dev/null); then
	command -v zsh >> /etc/shells
fi
# change login shell to zsh
if chsh -s "$(command -v zsh)"; then
	echo "login shell is changed to zsh"
else
	err "failed to change login shell to zsh, aborted"
	exit 3
fi

#set timezone to Asia/Shanghai
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# install vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
				http://realrz.com/scripts/plug.vim

# set vim as default editor
if [[ "$distro" != "FreeBSD" ]]; then
	update-alternatives --set editor /usr/bin/vim.basic
fi

# custom vim config
curl -L https://raw.githubusercontent.com/librz/shell_scripts/main/.vimrc > ~/.vimrc
# custom zsh config
curl -L https://raw.githubusercontent.com/librz/shell_scripts/main/.zshrc > ~/.zshrc

# change ssh listen port(sshd port) to 9000, set ClientAliveInterval to 5 seconds
# different ISO providers may have different sshd_config, so this may not work
sed -i 's/#Port 22/Port 9000/g' /etc/ssh/sshd_config
sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 5/g' /etc/ssh/sshd_config
service sshd restart

echo "some of these changes require re-login to be effective"
