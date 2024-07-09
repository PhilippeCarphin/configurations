
# echo "MANPATH start config.fish : '$MANPATH'"
#
# From https://fish-users.narkive.com/qmgw3G37/ls-colors-with-fish
# set -Ux LSCOLORS Exfxcxdxbxegedabagacad
# From https://apple.stackexchange.com/a/33679
set -x LSCOLORS ExGxBxDxCxEgEdxbxgxcxd

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# eval /Users/pcarphin/miniforge3/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<
alias n='nnn -dHQex'
set -x STOW_DIR $HOME/fs
for f in (env -i ls $STOW_DIR/etc/fish_completion.d/)
    source $STOW_DIR/etc/fish_completion.d/$f
end

# The '|| true' is because that script ends with
# unsetting a variable that may not exist
# It is not necessary in this context of shell startup
# but I'm leaing it there to know that this is something
# that the script does.
# echo "MANPATH before module : '$MANPATH'"
source /opt/homebrew/opt/modules/init/fish || true
# Because module load may set MANPATH to something
# The man program maps paths in $PATH to paths for manpages:
# $a_path -> $a_path/../share/man
# so by having a repo
# repo
# ├── bin
# │   └── myexec
# └── share
#     └── man
#         └── man1
#             └── myexec.1
# we don't need to add anything to MANPATH because adding repo/bin
# is sufficient.
#
# However, BSD man STOPS DOING THIS when the variable MANPATH has a value.
#
# So in this case, either apply the MANPATH map myself
# string replace --regex --all '/bin/?:' '/share/man:' $PATH

# if test "$MANPATH" = ":"
#     set -e MANPATH
# end
# echo "MANPATH after module : '$MANPATH'"

# echo "MANPATH = '$MANPATH'"
# echo $MANPATH

if test -n "$MANPATH"
    # This would do the manpath mapping thing manually,
	set MANPATH $MANPATH (string replace --regex --all '/bin/?$' '/share/man' $PATH)
	# echo "MANPATH = '$MANPATH'"
    set MANPATH $MANPATH /Library/Developer/CommandLineTools/usr/share/man
end

# set -e MANPATH
# set -x MODULEPATH $MODULEPATH:$HOME/.modules
# source $HOME/Documents/GitHub/stow-completion/stow_completion.fish
alias make='make VERBOSE='
# termcap terminfo
# ks     smkx     make the keypad send commands
# ke     rmkx     make the keypad send digits
# vb     flash    emit visual bell
# mb     blink    start blink
# md     bold     start bold
# me     sgr0     turn off bold, blink and underline
# so     smso     start standout (reverse video)
# se     rmso     stop standout
# us     smul     start underline
# ue     rmul     stop underline

# Make the man colorful
# Other color scheme for less
export LESS_TERMCAP_mb=\e"[1;34m"
export LESS_TERMCAP_md=\e"[1;36m"
export LESS_TERMCAP_me=\e"[0m"
export LESS_TERMCAP_se=\e"[0m"
export LESS_TERMCAP_so=\e"[01;33m"
export LESS_TERMCAP_ue=\e"[0m"
export LESS_TERMCAP_us=\e"[1;4;31m"


set PATH "/Users/pcarphin/perl5/bin" $PATH
set -x PERL5LIB "/Users/pcarphin/perl5/lib/perl5:$PERL5LIB"
set -x PERL_LOCAL_LIB_ROOT "/Users/pcarphin/perl5:$PERL_LOCAL_LIB_ROOT"
set -x PERL_MB_OPT "--install_base \"/Users/pcarphin/perl5\""
set -x PERL_MM_OPT "INSTALL_BASE=/Users/pcarphin/perl5"

alias p.ps='ps -u pcarphin | cut -c -(tput cols) | sort -k 5'
