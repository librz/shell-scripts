#!/bin/sh

# install common softwares
apt update && apt install zsh tldr tree net-tools
if [[ $? -ne 0]]: then
	echo "apt install failed"
	exit 1
fi
echo "zsh, tldr, tree, net-tools installed"

# chang shell to zsh
chsh -s $(which zsh) && echo "switched login shell to zsh, you may need to re-login for this to take effect"

# custom vim config
curl https://raw.githubusercontent.com/Patrick-Ren/shell_scripts/main/.vimrc > ~/.vimrc
# custom zsh config
curl https://raw.githubusercontent.com/Patrick-Ren/shell_scripts/main/.zshrc > ~/.zshrc

echo "custom .vimrc and .zshrc is in place"

# change ssh listen port(sshd port) to 9000, use default ClientAliveInterval
sed -i 's/#Port 22/Port 9000/g' /etc/ssh/sshd_config
sed -i 's/#ClientAliveInterval/ClientAliveInterval/g' /etc/ssh/sshd_config
echo "ssh listen port is set to 9000, ClientAliveInterval is enabled"

# set timezone to Asia/Shanghai
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
echo "timzeon is set to Asia/Shanghai"

exit 0
