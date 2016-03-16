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

Plugin 'https://github.com/steffanc/cscopemaps.vim'

" Extra plugins to add with vundle go here
Plugin 'Valloric/YouCompleteMe'

Plugin 'Lokaltog/vim-powerline'

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


" For vim-powerline
set laststatus=2


" ===========================================================
if has('cscope')
  set cscopetag cscopeverbose

  if has('quickfix')
    set cscopequickfix=s-,c-,d-,i-,t-,e-
  endif

  cnoreabbrev csa cs add
  cnoreabbrev csf cs find
  cnoreabbrev csk cs kill
  cnoreabbrev csr cs reset
  cnoreabbrev css cs show
  cnoreabbrev csh cs help

  command -nargs=0 Cscope cs add $VIMSRC/src/cscope.out $VIMSRC/src
endif



"======================= END VUNDLE =========================
" From the 'vim as a C/C++ IDE'
" http://www.alexeyshmalko.com/2014/using-vim-as-c-cpp-ide/
" set exrc "Allows automatic sourcing of project specific vimrc
" set secure "Fixes security hole caused by previous command. 
"


" ================
" http://stackoverflow.com/questions/234564/tab-key-4-spaces-and-auto-indent-after-curly-braces-in-vim/21323445#21323445
" Only do this part when compiled with support for autocommands.
if has("autocmd")
    " Use filetype detection and file-based automatic indenting.
    filetype plugin indent on

    " Use actual tab chars in Makefiles.
    autocmd FileType make set tabstop=8 shiftwidth=8 softtabstop=0 noexpandtab
endif

" For everything else, use a tab width of 3 space chars.
set tabstop=3       " The width of a TAB is set to 3.
                    " Still it is a \t. It is just that
                    " Vim will interpret it to be having
                    " a width of 3.
set shiftwidth=3    " Indents will have a width of 3.
set softtabstop=3   " Sets the number of columns for a TAB.
set expandtab       " Expand TABs to spaces.
" ===============

set autoindent
" hi Tab gui=underline guifg=blue ctermbg=blue
" Wrapping
set wrap 
" set linebreak 
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
nnoremap <C-d> :w:!./%
" nnoremap <C-b> :w | :!make<CR>
set number
" nnoremap <C-i> =i{
cnoremap vr<CR> :split ~/.vimrc<CR>
cnoremap sv<CR> :source ~/.vimrc<CR>
" New Section
" nnoremap <Down> ddp
syntax on

set backspace=indent,eol,start
" To enable 256 colors in vim, put this your .vimrc before setting the colorscheme:
set t_Co=256
" You may also need to add: 
"set t_AB=^[[48;5;%dm
"set t_AF=^[[38;5;%dm

" Non-retarded backspace behavior
:set backspace=2
" set foldmethod=indent

set foldnestmax=1

" colorscheme morning
" colorscheme monokai
colorscheme molokai
