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
set tabstop=4       " The width of a TAB is set to 3.
                    " Still it is a \t. It is just that
                    " Vim will interpret it to be having
                    " a width of 3.
set shiftwidth=4    " Indents will have a width of 3.
set softtabstop=4   " Sets the number of columns for a TAB.
set noexpandtab       " Expand TABs to spaces.
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

" Phil
" Tell vim to remember certain things when we exit
"  '10  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
" set viminfo='10,\"100,:20,%,n~/.viminfo

" Remember position in file 
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal!  g'\"" | endif
endif

inoremap jk <ESC>
" vnoremap jk <ESC>
" set nohlsearch
set hlsearch
nnoremap <C-l> :w:!pdflatex %
inoremap <C-l> <ESC>:w:!pdflatex %
nnoremap <C-d> :w:!%:p
" nnoremap <C-d> :w:!%
nnoremap <C-b> :w:!cc % -D_BSD_SOURCE -std=c11 && ./a.out
nnoremap <C-m> :w:!make test
set number
cnoremap vr split ~/.vimrc
cnoremap sv source ~/.vimrc
command Now r!date
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

set foldnestmax=1

" colorscheme morning
" colorscheme monokai
colorscheme molokai

" Easy interaction with system CTRL-C buffer.
nnoremap <C-y> "+yy
vnoremap <C-y> "+y
nnoremap <C-p> "+p

" Have a column with a different color to make me feel bad when I go over 120
" chars.  Should be 80, but if you look at the C code for maestro, you'll see
" that this is completely unrealistic.
set colorcolumn=80

nnoremap <C-c> I/* <ESC>A */<ESC>
nnoremap <C-u> :s/\/\* \?//\|s/ \?\*\//<CR>:nohlsearch<CR>

" nnoremap <Up> <ESC>:echoerr "Your mind is weak."<CR>
" nnoremap <Down> <ESC>:echoerr "Your mind is weak."<CR>
" nnoremap <Left> <ESC>:echoerr "Your mind is weak."<CR>
" nnoremap <Right> <ESC>:echoerr "Your mind is weak."<CR>
nnoremap <Up> <C-y>k
" nnoremap <Up> <C-y>
nnoremap <Down> <C-e>j
" nnoremap <Down> <C-e>
nnoremap <Left> <ESC>:echoerr "Your mind is weak."<CR>
nnoremap <Right> <ESC>:echoerr "Your mind is weak."<CR>

inoremap <Up> <ESC>:echoerr "Join me or die"<CR>
inoremap <Down> <ESC>:echoerr "The clouded mind sees nothing"<CR>
inoremap <Left> <ESC>:echoerr "Your mind is weak."<CR>
inoremap <Right> <ESC>:echoerr "The clouded mind sees nothing"<CR>

command! Notes tabe ~/Desktop/Notes/Daily_Notes/today.txt
nnoremap U yyp^v$r=

"  Not sure about this: it is for display word wrapping. It makes it work with
"  indentation, but it breaks up words.  Broken up words is not as bad for
"  understanding the code as not having clear visual indentation so I'm going to
"  use it.  The ideal solution would be to use
if v:version >= 704
    set breakindent
endif
"  but also figure out which extra option to set so that it doesn't break up
"  words. See also showbreak

"  Redo line breaks for a paragraph
nnoremap <C-j> {jV}kJgqgq
vnoremap <C-j> Jgqgq
nnoremap <C-h> O/79a*yypxjkA/ko

:inoremap <C-u> yyp^v$r-o	
:inoremap <C-U> yyp^v$r=o	

