# util functions


function header() {
	echo -e "\n** $1 **\n"
}

function err() {
	echo "$1" >&2
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

# set zsh to use vi mode & remap escape key to jk
bindkey -v
bindkey jk vi-cmd-mode
# set terminal tab-width to 2 columns 
tabs -2

# ---------- global variables ----------

# remote repo addr
repoAddr="https://realrz.com/shell-scripts"

distro="$(getDistro)" 
export distro

# nice simple colored prompt (%f means reset color?)
export PS1="%10F%n%f@%12F%m%f%3F:%~%f %10F$%f "

# locale setting
export LC_ALL="en_US.UTF-8"
export LANG="zh_CN.UTF-8"

# ---------- end of global variables ----------

# set vim as default editor
if [[ "$distro" == "Debian" || "$distro" == "Ubuntu" ]]; then
	update-alternatives --set editor "$(command -v vim)"
else
	# export EDITOR as environment variable
	# this will set vim as default editor on macOS
	EDITOR=$(command -v vim)
	export EDITOR
fi

setopt autocd # change directory just by typing its name

# ---- aliases and functions ----

# cs: config system 
alias cs="bash <(curl -sL $repoAddr/init.sh)"

# edit/source zsh config
alias zc='vim ~/.zshrc'
alias sz="source ~/.zshrc"
# edit vim config
alias vc="vim ~/.vimrc"

alias b="cd .."
alias c='clear'
alias v='vim'
alias ls='ls --color=auto'
alias wh='which'
alias sc="shellcheck --shell=bash"

# long formated ls sort by file size
alias lls="ls -AlhS"

# gh for go home
alias gh="cd ~"

# pubip & myip for public ip address
# ifconfig.me & ident.me both provide this type of service
alias pubip="curl ifconfig.me"
alias myip="curl ident.me"
# if you are inside gfw
alias gfwip="curl http://pv.sohu.com/cityjson"
alias wallip="curl curl https://api.myip.com"

# -------- git related ---------

# sac: stage all changes(under current folder) and commit(with a message)
alias sac="git add . && git commit -m"

# gs: git status
alias gs="git status"

# gl: formatted git log, placeholder starts with % sign, see: https://git-scm.com/docs/pretty-formats
alias gl='git log --pretty="%Cgreen%h %Creset%ae %ar %C(cyan)<%s>"'

# gb: git branch
alias gb="git branch"

# gc: git checkout
alias gc="git checkout"

# gp: git push
alias gp="git push"

# gm: git merge
alias gm="git merge"

# gds: git diff --shortstat
alias gds="git diff --shortstat"

# gdac: git discard all changes
function gdac () {
	git clean -df
	git checkout -- .
}

# nb: new branch from upstream/master
function nb () {
	git fetch upstream
	git checkout upstream/master
	git checkout -b "$1"
}

# -------- end of git related ------

# list the PATH environment variable(one path per row, sort by path length)
lpath() {
	echo "$PATH" | awk -v RS=":" '{print length, $1}' | sort -n -s | awk '{print $2}'
}

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
	df -H | awk '
		NR==1 {
			for (i=1; i<=NF; i++) {
				if ($i == "Size") sizeIndex = i
				if ($i == "Avail") availIndex = i
				if ($i == "Mounted") mountedIndex = i
			}
		}
		$mountedIndex=="/" {
			print $availIndex, "of", $sizeIndex, "is available"
		}
	'
}

# print out directory size
dirsize () {
	local depthOption="--max-depth"
	if [[ "$distro" == "macOS" ]]; then
		depthOption="-d"
	fi
	du -h "$depthOption"=1 "$1" | tail -1 | awk '{print $1}'
}

# sop: scan open port
sop () {
	# better use nmap
	# although you could use netstat or ss, they work differently between macOS & linux
	nmap localhost | grep "/tcp" | awk -F'/' '{print $1}'
}

# 3p: program, pid, port
alias 3p="bash <(curl -sL $repoAddr/3p.sh)"

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

# ghs: generate html skeleton
ghs () {
	local html
	html=$(
cat << EOF
<html>
	<head>
		<title></title>
	</head>
	<body>
	</body>
</html>
EOF
)
	echo "$html"
}

# mac specific settins
if [[ -e ~/.zshrc_mac ]]; then
	# shellcheck source=/dev/null
	source ~/.zshrc_mac
fi

# private settings, DO NOT make it public
# things like aliases for ssh into your vps, shell http/https proxy settings, added path to the PATH variable 
if [[ -e ~/.zshrc_private ]]; then
	# shellcheck source=/dev/null
	source ~/.zshrc_private
fi
