#!/bin/bash

# linux init script, run this to set up and config the system
# it supports Debian/Ubuntu, macOS 
# usage: bash <(curl -sL http://realrz.com/shell-scripts/init.sh)

# if you want the latest configs, just run this script again after it's updated

function err {
	echo "$1" >&2
}

# check distro
if ! distro=$(bash <(curl -sL http://realrz.com/shell-scripts/distro.sh)); then
	exit 1
fi
echo "You are running: $distro"

# install common softwares
if [[ "$distro" == "Debian" || "$distro" == "Ubuntu" ]]; then
	apt update
	if yes | apt install zsh vim git snapd curl tldr tree xxd net-tools nmap dnsutils; then
		echo "apt install succeeded"
	else
		err "apt install failed"
		exit 2
	fi
else
	# distro is macOS
	echo "use homebrew to manually install softwares on macOS"
fi

# language-pack-zh-hans is only aviailable in ubuntu 
if [[ "$distro" = "Ubuntu" ]]; then
	# also install language-pack-zh-hans
	yes | apt install language-pack-zh-hans
fi

# add zsh to /etc/shells if it's not there
if ! (grep zsh /etc/shells &>/dev/null); then
	command -v zsh >> /etc/shells
fi
# change login shell to zsh
if chsh -s "$(command -v zsh)"; then
	echo "login shell is changed to zsh"
else
	err "failed to change login shell to zsh"
	exit 3
fi

#set timezone to Asia/Shanghai
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# install vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
				http://realrz.com/shell-scripts/plug.vim

# custom vim config
curl -L http://realrz.com/shell-scripts/.vimrc > ~/.vimrc
# custom zsh config
curl -L http://realrz.com/shell-scripts/.zshrc > ~/.zshrc

if [[ "$distro" != "macOS" ]]; then
	# change ssh listen port(sshd port) to 9000, set ClientAliveInterval to 5 seconds
	# different ISO providers may have different sshd_config, so this may not work
	sed -i 's/#Port 22/Port 9000/g' /etc/ssh/sshd_config
	sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 5/g' /etc/ssh/sshd_config
	service sshd restart
fi

echo "some of these changes may require re-login to be effective"
