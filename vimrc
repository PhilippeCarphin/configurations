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

" Extra plugins to add with vundle go here
" Plugin 'wakatime/vim-wakatime'
Plugin 'nelstrom/vim-markdown-folding'

Plugin 'jceb/vim-orgmode'

Plugin 'https://github.com/steffanc/cscopemaps.vim'

Plugin 'Valloric/YouCompleteMe'

Plugin 'Lokaltog/vim-powerline'

Plugin 'https://github.com/scrooloose/nerdtree'

Plugin 'tpope/vim-fugitive.git'

Plugin 'hari-rangarajan/CCTree'

Plugin 'wikitopian/hardmode'
" :call HardMode()
" :call EasyMode()

" Plugin to highlight trailing whitespace and provides a function to clear
" whitespace in the whole file or a range.
Plugin 'ntpeters/vim-better-whitespace'

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

" For vim-powerline
set laststatus=2
set t_Co=256
set encoding=utf-8

" Nerdtree
   autocmd StdinReadPre * let s:std_in=1
   autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
" End nerdtree

" ===================== CSCOPE ==============================
" Cscope seems to work without any of this but they must do something useful and
" besides, I found them on the vim wiki, so it's probably quite standard.  I
" only use the 'csf' abbreviation which I modified from the wiki to
" automatically add the 'g' because I use it in vim to jump to definition.  The
" other possible letters correspond to the options in command line cscope.
" The set ... command is what causes cscope database to be created when I start
" I don't know what else it does.
" As for the command -nargs ... I don't know what it does and it causes an error
" message to be printed when I sourse my vimrc within vim because it says that
" the command I'm trying to define already exists.  So I'm commenting it out.
" http://vim.wikia.com/wiki/VimTip1638
if has('cscope')
  set cscopetag cscopeverbose
  if has('quickfix')
    set cscopequickfix=s-,c-,d-,i-,t-,e-
  endif
  cnoreabbrev csa cs add
  cnoreabbrev csf cs find g
  cnoreabbrev csk cs kill
  cnoreabbrev csr cs reset
  cnoreabbrev css cs show
  cnoreabbrev csh cs help
  " command -nargs=0 Cscope cs add $VIMSRC/src/cscope.out $VIMSRC/src
endif

" From the 'vim as a C/C++ IDE'
" http://www.alexeyshmalko.com/2014/using-vim-as-c-cpp-ide/
set exrc "Allows automatic sourcing of project specific vimrc
set secure "Fixes security hole caused by previous command.

" ================
" http://stackoverflow.com/questions/234564/tab-key-4-spaces-and-auto-indent-after-curly-braces-in-vim/21323445#21323445
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

set scrolloff=5

set hlsearch

set number
syntax on
" Display incomplete commands at the right
set showcmd
" Usual backspace behavior
set backspace=indent,eol,start
" Non-retarded backspace behavior
set backspace=2
" Note: probably only one of the two preceding commands is necessary.

" To enable 256 colors in vim, put this your .vimrc before setting the colorscheme:
set t_Co=256
colorscheme molokai
set foldnestmax=1
set colorcolumn=80
set clipboard=unnamed
 " if v:version >= 704
 "     set breakindent
 " endif

" Remember position in file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal!  g'\"" | endif
endif

inoremap jk <ESC>
nnoremap <C-b> :wa:!clear;FILE=% make
inoremap <C-b> <ESC>:wa:!makeli

cnoremap vr split ~/.vimrc
cnoremap sv source ~/.vimrc
command! Now r!TZ=America/New_York date

nnoremap <Up> <C-y>k
nnoremap <Down> <C-e>j
nnoremap <Left> <ESC>:echoerr "Your mind is weak."<CR>
nnoremap <Right> <ESC>:echoerr "Your mind is weak."<CR>

inoremap <Up> <ESC>:echoerr "Join me or die"<CR>
inoremap <Down> <ESC>:echoerr "The clouded mind sees nothing"<CR>
inoremap <Left> <ESC>:echoerr "Your mind is weak."<CR>
inoremap <Right> <ESC>:echoerr "The clouded mind sees nothing"<CR>

command! Notes tabe ~/Desktop/Notes/Daily_Notes/today.txt
nnoremap U yyp^v$r=

"  Redo line breaks for a paragraph
nnoremap <C-j> {jV}kJgqgq
vnoremap <C-j> Jgqgq

" Make a C-style header that I like so much
nnoremap <C-h> O/79a*yypxjkA/ko
nnoremap <C-g> 0f(bywk:r ~/Documents/GitHub/utils/misc/cmc_header.c<CR>/Nom<CR>$a <<ESC>pA><ESC>

"  For when I try to open a file like I was in a terminal but I forgot that I'm
"  in vim.
nnoremap vim :tabe
cnoremap vim tabe

:inoremap <C-u> yyp^v$r-o
:inoremap <C-U> yyp^v$r=o

nnoremap <SPACE>w <C-w>

let g:ycm_confirm_extra_conf = 0
let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'

