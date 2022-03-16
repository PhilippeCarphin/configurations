
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
end

# set -e MANPATH
# set -x MODULEPATH $MODULEPATH:$HOME/.modules
# source $HOME/Documents/GitHub/stow-completion/stow_completion.fish
