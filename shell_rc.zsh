#!/bin/zsh

source ${STOW_DIR}/etc/zsh_completion.d/repos_completion.zsh
source /opt/homebrew/opt/modules/init/zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source $HOME/Repositories/github.com/philippecarphin/bash-powerline/powerline.zsh
source $HOME/Repositories/github.com/philippecarphin/utils/etc/profile.d/git-colon-path-support.zsh

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
