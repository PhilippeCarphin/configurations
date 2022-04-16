
# From https://fish-users.narkive.com/qmgw3G37/ls-colors-with-fish
# set -Ux LSCOLORS Exfxcxdxbxegedabagacad
# From https://apple.stackexchange.com/a/33679
set -x LSCOLORS ExGxBxDxCxEgEdxbxgxcxd
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# eval /Users/pcarphin/miniforge3/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<
alias n='nnn -dHQex'
for f in (find $STOW_DIR/etc/fish_completion.d/ -type f)
    source $f
end

# set -e MANPATH
set fish_module /opt/homebrew/opt/modules/init/fish
if test -f $fish_module ;
    # The '|| true' is because that script ends with
    # unsetting a variable that may not exist
    # It is not necessary in this context of shell startup
    # but I'm leaing it there to know that this is something
    # that the script does.
    source $fish_module || true
end

# set -x MODULEPATH $MODULEPATH:$HOME/.modules
# source $HOME/Documents/GitHub/stow-completion/stow_completion.fish

