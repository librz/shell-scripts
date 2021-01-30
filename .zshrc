# change prompt
export PS1="%10F%m%f:%11F%1~%f \$ "

# locale setting
export LC_ALL="en_US.UTF-8"
export LANG="zh_CN.UTF-8"

# set zsh to use vi mode & remap escape key to jk
bindkey -v
bindkey jk vi-cmd-mode

# set tab size in shell to 2 spaces
tabs -2

# edit/source zsh config
alias zc='vim ~/.zshrc'
alias sz="source ~/.zshrc"
# edit vim config
alias vc="vim ~/.vimrc"

# colored ls
alias ls="ls --color=auto"

alias b="cd .. && echo -n 'back to ' && pwd"
alias c='clear'
alias v='vim'
alias h='history'
alias w='which'

# dates
alias today='date --rfc-3339=date'
alias yesterday='date --date="-1 day" --rfc-3339=date'
alias tomorrow='date --date="+1 day" --rfc-3339=date'

# gh for go home
alias gh="cd ~"

# bye for logout
alias bye="logout"

# mcd for mkdir && cd
mcd() {
	mkdir $1 && cd $1
}

# p5 for ping 5 times
alias p5="ping -c 5"

# pubip & myip for public ip address
# ifconfig.me & ident.me both provide this type of service
alias pubip="curl ifconfig.me"
alias myip="curl ident.me"

# scan open port on "this" machine
alias sop="netstat -tln | awk '(NR>2) {print \$4}' | rev | cut -d':' -f1 | rev | sort -n | uniq"

# how much disk space is left
space () {
				df -h | awk '($6=="/"){print $5, "of", $2, "is used"}'
}

# how large is a directory
dirsize () {
	du -sh $1 | awk '{print $1}'
}

# 3p: program, process, port 
alias 3p="bash <(curl -sL https://raw.githubusercontent.com/librz/shell_scripts/main/3p.sh)"

# -------- git related ---------
# sac: stage all changes and commit
alias sac="git add . && git commit -m"

# gs: git status
alias gs="git status"

