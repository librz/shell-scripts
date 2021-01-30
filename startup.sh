#!/bin/bash

# install common softwares
apt update && yes Y | apt install zsh vim git snapd curl tldr tree net-tools dnsutils language-pack-zh-hans

# chang shell to zsh
chsh -s "$(which zsh)" 

# set timezone to Asia/Shanghai
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# set vim as default editor
update-alternatives --set editor /usr/bin/vim.basic

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
