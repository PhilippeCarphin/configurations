
"====================== BEGIN VUNDLE ========================

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
" call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" " The following are examples of different formats supported.
" " Keep Plugin commands between vundle#begin/end.
" " plugin on GitHub repo
" Plugin 'tpope/vim-fugitive'
" " plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" " Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" " git repos on your local machine (i.e. when working on your own plugin)
" Plugin 'file:///home/gmarik/path/to/plugin'
" " The sparkup vim script is in a subdirectory of this repo called vim.
" " Pass the path to set the runtimepath properly.
" Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" " Avoid a name conflict with L9
" Plugin 'user/L9', {'name': 'newL9'}


" Plugin 'Valloric/YouCompleteMe'


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList          - list configured plugins
" :PluginInstall(!)    - install (update) plugins
" :PluginSearch(!) foo - search (or refresh cache first) for foo
" :PluginClean(!)      - confirm (or auto-approve) removal of unused plugins
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line








"======================= END VUNDLE =========================
" From the 'vim as a C/C++ IDE'
" http://www.alexeyshmalko.com/2014/using-vim-as-c-cpp-ide/
" set exrc "Allows automatic sourcing of project specific vimrc
" set secure "Fixes security hole caused by previous command. 
"
"
"
"
" Normal indentation
set tabstop=2
" set softtabstop=2
set shiftwidth=2
" set expandtab
set autoindent
hi Tab gui=underline guifg=blue ctermbg=blue
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
" set nohlsearch
set hlsearch
nnoremap <C-b> :w:!gcc % -std=c99 && ./a.out
" nnoremap <C-b> :w | :!make<CR>
set number
" nnoremap <C-i> =i{
cnoremap vr<CR> :split ~/.vimrc<CR>
cnoremap sv<CR> :source ~/.vimrc<CR>
" New Section
" nnoremap <Down> ddp
syntax on

" To enable 256 colors in vim, put this your .vimrc before setting the colorscheme:
set t_Co=256
" You may also need to add: 
"set t_AB=^[[48;5;%dm
"set t_AF=^[[38;5;%dm

" Non-retarded backspace behavior
:set backspace=2
" set foldmethod=indent


colorscheme molokai
