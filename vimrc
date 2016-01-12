" From the 'vim as a C/C++ IDE'
" http://www.alexeyshmalko.com/2014/using-vim-as-c-cpp-ide/
set exrc "Allows automatic sourcing of project specific vimrc
set secure "Fixes security hole caused by previous command. 
colorscheme slate
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

inoremap jk <ESC>
set nohlsearch
nnoremap <C-m> :w <CR> :!make run <CR>
set number

" New Section

syntax on
