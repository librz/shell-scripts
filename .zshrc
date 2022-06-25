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

# terminal prompt (%f means reset color; %F{color} format color, just google "shell format color" for available colors)
# ref: https://zsh-prompt-generator.site/
PROMPT="%F{yellow}%h%f %F{magenta}%~%f 🚀 "
RPROMPT="%(?.%F{green}.%F{red})%?%f"

# locale setting
export LC_ALL="en_US.UTF-8"
export LANG="zh_CN.UTF-8"

# ---------- end of global variables ----------

# set vim as default editor
if command -v vim &> /dev/null; then
  if [[ "$distro" == "Ubuntu" ]]; then
    update-alternatives --set editor /usr/bin/vim.basic
  else
    # export EDITOR as environment variable
    # this will set vim as default editor on macOS
    EDITOR=$(command -v vim)
    export EDITOR
  fi  
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
alias his='history -d'
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

# -------- git related ---------

# gb: git branch
alias gb="git branch"

# gcm: git commit -m
alias gcm="git commit -m"

# gs: git status
alias gs="git status"

# gl: formatted git log, placeholder starts with % sign, see: https://git-scm.com/docs/pretty-formats
alias gl='git log --pretty="%Cgreen%h %Creset%ae %ar %C(cyan)<%s>"'

# gds: git diff --shortstat
alias gds="git diff --shortstat"

# gdb: git delete branch (by regex)
function gdb () {
	# basic check
	if ! git status &> /dev/null
	then
		echo "You are not inside a git repo"
		return 1
	fi

	# get repo type (local or remote)
	echo "1. Local branch(es)"
	echo "2. Remote branch(es)"
	echo -n "Which type of branch(es) to delete(1 or 2): "
	read -r repo_type
	if [[ "$repo_type" -ne 1 && "$repo_type" -ne 2 ]]; then
		echo "Only 1 or 2 are permitted"
		return 1
	fi

	if [[ "$repo_type" -eq 2 ]]; then
		# get remote name
		echo
		git remote
		echo
		echo -n "Which remote is your target: "
		read -r remote
		if ! git remote | grep -q "$remote"
		then
			echo "No such remote"
			return 1
		fi
	fi

	# list out all branches
	echo
	if [[ "$repo_type" -eq 1 ]]; then
		all_branches_count=$(git branch | grep -c '^')
		echo "Found $all_branches_count local branches"
		echo
		git branch
	else
		# fetching branches for that remote
		echo "Fetching branches on $remote"
		echo
		git fetch --prune
		all_branches=$(git branch -a | grep -i "remotes/${remote}")
		all_branch_count=$(echo -n "$all_branches" | grep -c '^')
		echo "Found $all_branch_count branches on ${remote}"
		echo
		echo "$all_branches"
	fi

	# ask for branch regex
	echo
	echo -n "Branch regex (no need to surround it with //): "
  read -r branch_regex

	# get branches to delete
	if [[ "$repo_type" -eq 1 ]]; then
		branches=$(git branch | awk -v pattern="$branch_regex" '$1 ~ pattern {print $1}')
	else
		branches=$(git branch -a | grep -i "remotes/${remote}" | awk -v pattern="$branch_regex" -F'/' '$3 ~ pattern {print $3}')
	fi
  branch_count=$(echo -n "$branches" | grep -c '^')
  if [[ "$branch_count" -eq 0 ]]
  then
    echo "No branch matched"
    return 1
  fi
  echo
  echo "$branch_count branches matched: "
  echo
  echo "$branches"
  echo

	# ask for confirmation
  echo -n "Delete all branches listed above? (Y/N): "
  read -r confirm
  echo
  if ! [[ "$confirm" =~ ^[Yy][Es]?[Ss]? ]]
  then
    echo "Aborted"
    return
  fi

	# delete branch one by one
  while IFS= read -r branch
  do
		if [[ "$repo_type" -eq 1 ]]; then
			git branch -D "$branch"
		else
    	git push "$remote" --delete "$branch"
		fi
  done <<< "$branches"

	echo
	echo "DONE"
}

# gdac: git discard all changes
function gdac () {
	git clean -df
	git checkout -- .
}

# nb: new branch from upstream/master
function nb () {
	git fetch upstream
	git checkout -b "$1" --no-track upstream/master
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
	# although you could use netstat or ss, they work differently under macOS & linux
	# -p- means scan all ports (1-65535)
	nmap -p- localhost | grep "/tcp" | awk -F'/' '{print $1}'
}

# 3p: program, pid, port
alias 3p="bash <(curl -sL $repoAddr/tools/3p.sh)"

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

# network info for ubuntu
ni_ubuntu () {
	local hwinfo=$(sudo lshw -c network) 

	# type: Wi-Fi or Ethernet
	echo -n "type: "
	local desp=$(echo "$hwinfo" | grep 'description')
	if echo "$desp" | grep -Ei 'wireless' &> /dev/null; then
		echo "Wi-Fi"
	else
		echo "Ethernet"
	fi

	# interface
	echo -n "interface: "
	local intfname=$(echo "$hwinfo" | grep 'logical name' | awk '{print $3}')
	echo "$intfname"

	# mac addr
	echo -n "MAC addr: "
	echo "$hwinfo" | grep 'serial' | awk '{print $2}'
	echo

	echo "**Netowrk Info**"
	echo

	echo -n "hostname: "
	hostname

	echo -n "private IP: "
	ifconfig "$intfname" | awk '/inet /{print $2}'

	# ubuntu uses systemd-resolve 
	echo -n "dns server: "
	resolvectl status | grep -i "current dns server" | awk -F': ' '{print $2}' 
	
	echo -n "gateway: "
	ip route | grep default | awk 'NR==1{print $3}'

	echo -n "public IP: "
	curl -sL ident.me 
	echo
}

# network info for mac
ni_mac () {
	local ports=$(networksetup -listallhardwareports)
	# Wi-Fi info
	local wifi_intf=$(echo "$ports" | awk '/Wi-Fi/{getline; print $2}')
	if [[ -n "$wifi_intf" ]]
	then
		local wifi_ip=$(ipconfig getifaddr "$wifi_intf")
		if [[ -n "$wifi_ip" ]]
		then
			echo "** Wi-Fi **"
			echo "interface: ${wifi_intf}"
			local wifi_mac=$(echo "$ports" | awk '/Wi-Fi$/{getline; getline; print $3}')
			echo "MAC addr: ${wifi_mac}"
			echo "private IP: $wifi_ip"
			echo
		fi
	fi

	# Ethernet info
	local eth_intf=$(echo "$ports" | awk '/Ethernet$/{getline; print $2}')
	if [[ -n "$eth_intf" ]]
	then
		local eth_ip=$(ipconfig getifaddr "$eth_intf")
		if [[ -n "$eth_ip" ]]
		then
			echo "** Ethernet **"
			echo "interface: ${eth_intf}"
			local eth_mac=$(echo "$ports" | awk '/Ethernet$/{getline; getline; print $3}')
			echo "MAC addr: ${eth_mac}"
			echo "private IP: $eth_ip"
			echo
		fi
	fi
	# hostname, nameserver, public ip
	echo "hostname: $(hostname)"
	local nameserver=$(scutil --dns | grep nameserver | awk '{print $3}' | sort | uniq)
	echo "nameserver: $nameserver"
	echo "public ip: $(curl -sL ident.me)"
}

# network info

ni () {
	if [[ "$distro" == "Ubuntu" ]]; then
		ni_ubuntu
	else
		ni_mac
	fi
}

# template generator
template () {
	echo "1) html"
	echo "2) react FC"
	echo -n "Enter number to generate template: "
	read -r option
	echo

# template preset
local html
local rfc
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
rfc=$(
cat << EOF
import { FC } from 'react'

interface IProps {}

const Component: FC<IProps> = () => {
	return (
		<div></div>
	)
}

export default Component
EOF
)
	# echo to stdout
	if [[ "$option" -eq 1 ]]; then
		echo "$html"
	elif [[ "$option" -eq 2 ]]; then
		echo "$rfc"
	else
		echo "wrong option"
		return 1
	fi
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
