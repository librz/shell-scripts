# print error to stderr
err() {
	echo "$1" >&2
}

# global variable distro
distro=$(bash <(curl -sL http://realrz.com/shell-scripts/distro.sh))

# on my Windows machine I'm still using bash instead of zsh 
if [[ "$distro" != "Windows" ]]; then
	# set zsh to use vi mode & remap escape key to jk
	bindkey -v
	bindkey jk vi-cmd-mode
	# nice simple colored prompt
	export PS1="%10F%m%f:%11F%1~%f \$ "
fi

# set terminal tab-width to be 2 columns 
tabs -2

# locale setting
export LC_ALL="en_US.UTF-8"
export LANG="zh_CN.UTF-8"

# set vim as default editor
if [[ "$distro" == "Debian" || "$distro" == "Ubuntu" ]]; then
	update-alternatives --set editor /usr/bin/vim.basic
else
	# export EDITOR as environment variable
	# this will set vim as default editor on macOS
	EDITOR=$(command -v vim)
	export EDITOR
fi

# ---- below are handy aliases and functions ----

# edit/source zsh config
alias zc='vim ~/.zshrc'
alias sz="source ~/.zshrc"
# edit vim config
alias vc="vim ~/.vimrc"

alias b="cd .."
alias c='clear'
alias v='vim'
alias bye='exit'
alias sc="shellcheck --shell=bash"

# long formated ls sort by file size
alias lls="ls -alhS"

# gh for go home
alias gh="cd ~"

# pubip & myip for public ip address
# ifconfig.me & ident.me both provide this type of service
alias pubip="curl ifconfig.me"
alias myip="curl ident.me"

# -------- git related ---------
# sac: stage all changes and commit
alias sac="git add . && git commit -m"

# gs: git status
alias gs="git status"
# -------- end of git related ------

# cs: config system 
alias cs="bash <(curl -sL http://realrz.com/shell-scripts/init.sh)"

# mcd for mkdir && cd
mcd() {
	mkdir "$1" && cd "$1" || return
}

# today in format "YYYY-MM-DD"
today () {
	if [[ "$distro" == "macOS" ]]; then
		date "+%Y-%m-%d"
	else
		date --rfc-3339=date
	fi
}

# how much disk space is left
space () {
	if [[ "$distro" == "macOS" || "$distro" == "Windows" ]]; then
		err "macOS is not supported"
	else
		df -h | awk '($6=="/"){print $5, "of", $2, "is used"}'
	fi
}

# sop: scan open port
sop () {
	# netstat works very differently in Linux & BSD based systems such as macOS
	if [[ "$distro" == "macOS" ]]; then
		netstat -n -f inet -p tcp | awk 'NR>2{print $4}' | awk -F'.' '{print $NF}' | sort -n | uniq
	elif [[ "$distro" == "Debian" || "$distro" == "Ubuntu" ]]; then
		netstat -tln | awk '(NR>2) {print $4}' | awk -F':' '{print $NF}' | sort -n | uniq
	else
		err "you system is not supported"
		# dont't use exit here, it quit the current shell
	fi
}

# 3p: program, pid, port
alias 3p="bash <(curl -sL http://realrz.com/shell-scripts/3p.sh)"

# print file as binary string
binary () {
	xxd -b -c 1 "$1" \
	| awk '{print $2}' \
 	| tr -d '\n' && echo	
}

# print file as hex string
hex () {
	xxd -c 1 "$1" \
	| awk '{print $2}' \
	| tr -d '\n' && echo
}

# print out cool emoji 
smile () {
	# f09f988e is utf-8 hex for emoji(smiling face with sunglasses)
	# 0a is ascii/utf-8 for line feed
	echo -n "f09f988e0a" | xxd -r -p
}

# source local specific zsh setting
# .zshrc_local should remain private since it contains sensitive info such as IP address
if [[ -e ~/.zshrc_local ]]; then
	source ~/.zshrc_local
fi

# source local bash zsh setting
if [[ -e ~/.bashrc_local ]]; then
	source ~/.bashrc_local
fi

# cd into home folder
cd ~ || exit
