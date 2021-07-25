" show line number
set number

" set tab space to 2
set tabstop=2
set shiftwidth=2

" set encoding to utf-8
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8

" remap esc to jk in insert mode
imap jk <Esc>
" remap ^  to ss in normal mode
nmap ss ^
" remap $ to ee in normal mode
nmap ee $

" vim-plug section
call plug#begin('~/.vim/plugged')

call plug#end()
