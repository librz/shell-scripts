" set encoding to utf-8
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8

" remap esc to jk in insert mode
imap jk <Esc>

" syntax highlighting
syntax on

" search settings
set incsearch
set ignorecase
set smartcase

" scroll the screen if distance(cur_line, bottom) < 8
set scrolloff=8

" show absolute & relative line number
set number 
set relativenumber

" Use a line cursor within insert mode and a block cursor everywhere else.
"
" Reference chart of values:
"   Ps = 0  -> blinking block.
"   Ps = 1  -> blinking block (default).
"   Ps = 2  -> steady block.
"   Ps = 3  -> blinking underline.
"   Ps = 4  -> steady underline.
"   Ps = 5  -> blinking bar (xterm).
"   Ps = 6  -> steady bar (xterm).
let &t_SI = "\e[5 q" " insert mode
let &t_EI = "\e[2 q" " other modes

" set tab space to 2
set tabstop=2
set shiftwidth=2

" using vim-plug as vim plugin manager 
call plug#begin('~/.vim/plugged')

call plug#end()
