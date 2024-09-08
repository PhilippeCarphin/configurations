#!/bin/zsh

source ${STOW_DIR}/etc/zsh_completion.d/repos_completion.zsh
source /opt/homebrew/opt/modules/init/zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source $HOME/Repositories/github.com/philippecarphin/bash-powerline/powerline.zsh
source $HOME/Repositories/github.com/philippecarphin/utils/etc/profile.d/git-colon-path-support.zsh
export PS4=$'+ \033[35m%N\033[0m:\033[32m%i\033[0m '

alias vim='wrap_command_colon_paths vim -p'
alias cd='wrap_command_colon_dirs cd'

# Set emacs keybindings.  ZSH looks at the EDITOR environment
# variable and since I have it set to vim, I need to do this.
bindkey -e

print-list(){
    (
        setopt sh_word_split
        eval "IFS=':' local a=(\${$1[@]})"
        local i=1
        for x in "${a[@]}" ; do
            printf "\033[35m%s\033[0m%s\033[36m%d\033[0m%s\033[32m%s\033[0m%s\n" \
                "elements" "[" "$((i++))" "]='" "$x" "'"
        done
    )
}
