# change prompt
export PS1="%10F%m%f:%11F%1~%f \$ "

# config locale
export LC_ALL=en_US.UTF-8
export LANG=zh_CN.UTF-8

# set zsh to use vi mode & remap escape key to jk
bindkey -v
bindkey jk vi-cmd-mode

# edit zsh config
alias zc='vim ~/.zshrc'
# edit vim config
alias vc="vim ~/.vimrc"

alias c='clear'
alias v='vim'

alias today='date --rfc-3339=date'
alias yesterday='date --date="-1 day" --rfc-3339=date'
alias tomorrow='date --date="+1 day" --rfc-3339=date'

# gh/gohome for go home
alias gh="cd ~"
alias gohome="cd ~"

# scan for open port on "this" machine, may not be altogether correct
alias sop="netstat -tulpn | awk '(NR >= 3){print $4}' | grep '::' | cut -d':' -f4"

# see how much disk is used, ds for disk status
alias ds="df -h | awk '/Filesystem|overlay/ {print $5}'"
