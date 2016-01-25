" From the 'vim as a C/C++ IDE'
" http://www.alexeyshmalko.com/2014/using-vim-as-c-cpp-ide/
set exrc "Allows automatic sourcing of project specific vimrc
set secure "Fixes security hole caused by previous command. 
colorscheme evening
" Normal indentation
set tabstop=4
set softtabstop=4
set shiftwidth=4
set noexpandtab
set autoindent

" Wrapping
set wrap 
set linebreak 
set nolist 
set textwidth=80 
set wrapmargin=0 

" Phil
" Tell vim to remember certain things when we exit
"  '10  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
" set viminfo='10,\"100,:20,%,n~/.viminfo


if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal!  g'\"" | endif
endif
inoremap jk <ESC>
set nohlsearch
nnoremap <C-m> :w<CR>:!gcc % -std=c99 && ./a.out<CR>
set number
" nnoremap <C-i> =i{
cnoremap vr<CR> :split ~/.vimrc<CR>
cnoremap sv<CR> :source ~/.vimrc<CR>
" New Section
" nnoremap <Down> ddp
syntax on
