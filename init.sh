#!/bin/bash

# linux init script, run this to set up and config the system
# it supports Debian/Ubuntu, macOS 
# usage: bash <(curl -sL http://realrz.com/shell-scripts/init.sh)

# if you want the latest configs, just run this script again after it's updated

function err {
	echo "$1" >&2
}

function header {
	echo "** $1 **"
}

# check distro
header "checking distro"
if ! distro=$(bash <(curl -sL http://realrz.com/shell-scripts/distro.sh)); then
	exit 1
fi
echo "You are running: $distro"

echo

# install softwares
header "installing common softwares"
if [[ "$distro" == "Debian" || "$distro" == "Ubuntu" ]]; then
	if apt update &>/dev/null && yes | apt install zsh vim git snapd curl tldr tree xxd net-tools nmap dnsutils; then
		echo "success"
	else
		err "apt install failed"
		exit 2
	fi
elif [[ "$distro" == "macOS" ]]; then
	echo "please use homebrew to manually install softwares on macOS"
elif [[ "$distro" == "Windows" ]]; then
	echo "please use scoop to manually install softwares on Windows"
fi

echo

# language-pack-zh-hans is only aviailable in ubuntu 
if [[ "$distro" = "Ubuntu" ]]; then
	header "installing language-pack-zh-hans"
	# also install language-pack-zh-hans
	yes | apt install language-pack-zh-hans
	echo "success"
fi

# add zsh to /etc/shells if it's not there
if ! grep -q zsh /etc/shells; then
	command -v zsh >> /etc/shells
fi

# change login shell to zsh
if [[ "$distro" != "Windows" ]]; then
	header "Changing login shell to zsh"
	if chsh -s "$(command -v zsh)"; then
		echo "login shell is changed to zsh"
	else
		err "failed to change login shell to zsh"
		exit 3
	fi
fi

echo

header "setting timezone to Asia/Shanghai"
if ! diff /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; then
	cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
fi
echo "success"

echo

header "installing vim-plug"
curl -sfLo ~/.vim/autoload/plug.vim --create-dirs http://realrz.com/shell-scripts/plug.vim
echo "success"

echo

header "configuring .vimrc & .zshrc"
curl -sL http://realrz.com/shell-scripts/.vimrc > ~/.vimrc
curl -sL http://realrz.com/shell-scripts/.zshrc > ~/.zshrc
echo "success"

echo

if [[ "$distro" != "macOS" && "$distro" != "Windows"]]; then
	# change sshd port to 9000, set ClientAliveInterval to 5 seconds
	# different ISO providers may have different sshd_config, so this may not work
	sed -i 's/#Port 22/Port 9000/g' /etc/ssh/sshd_config
	sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 5/g' /etc/ssh/sshd_config
	service sshd restart
fi

echo

echo "system config finished, some changes may require re-login to be effective"
