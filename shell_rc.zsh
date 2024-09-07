#!/bin/zsh

source ${STOW_DIR}/etc/zsh_completion.d/repos_completion.zsh
source /opt/homebrew/opt/modules/init/zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source $HOME/Repositories/github.com/philippecarphin/bash-powerline/powerline.zsh
source $HOME/Repositories/github.com/philippecarphin/utils/etc/profile.d/git-colon-path-support.zsh
export PS4=$'+ \033[35m%N\033[0m:\033[32m%i\033[0m '

alias vim='wrap_command_colon_paths vim -p'
alias cd='wrap_command_colon_dirs cd'

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/Users/pcarphin/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/Users/pcarphin/miniforge3/etc/profile.d/conda.sh" ]; then
#         . "/Users/pcarphin/miniforge3/etc/profile.d/conda.sh"
#     else
#         export PATH="/Users/pcarphin/miniforge3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# <<< conda initialize <<<
