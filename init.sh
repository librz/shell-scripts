#!/bin/bash

# linux init script, run this to set up and config the system
# it supports Debian/Ubuntu, macOS 
# usage: bash <(curl -sL http://realrz.com/shell-scripts/init.sh)

# if you want the latest configs, just run this script again after it's updated

# bring in utils functions
for f in ./utils/*.sh;
do
	source "$f"
done

# check distro
header "Checking Distro"
if ! distro=$(getDistro); then
	exit 1
fi
echo "You are running: $distro"

# auto remove
header "Removing unnecessary pacakges using apt autoremove"
yes | apt autoremove

# install softwares
header "Installing Common Software Packages"
if [[ "$distro" == "Debian" || "$distro" == "Ubuntu" ]]; then
	if apt update &>/dev/null && yes | apt install zsh vim git snapd curl tldr tree xxd net-tools nmap dnsutils; then
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
curl -sfLo ~/.vim/autoload/plug.vim --create-dirs http://realrz.com/shell-scripts/plug.vim
echo "success"

header "Configuring .vimrc & .zshrc"
curl -sL http://realrz.com/shell-scripts/.vimrc > ~/.vimrc
curl -sL http://realrz.com/shell-scripts/.zshrc > ~/.zshrc
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

header "System Config Finished, You Can Source It Now, Some Changes May Require re-login to be Effective"
