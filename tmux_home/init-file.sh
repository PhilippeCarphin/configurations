#
# For shared accounts, I launch a tmux session with
#
#     set -g default-command ... bash --init-file THIS_FILE
#
# so that I can have things the way I want without changing it for other users
#

# When launching bash with --init-file, it doesn't load /etc/profile or
# ~/.profile so we do it ourselves
source /etc/profile
source ~/.profile

# Make my stuff available
PATH=/home/phc001/fs1/bin:$PATH
LD_LIBRARY_PATH=/home/phc001/fs1/lib:${LD_LIBRARY_PATH}
XDG_DATA_DIRS=/home/phc001/fs1/share${XDG_DATA_DIRS:+:${XDG_DATA_DIRS}}

XDG_DATA_DIRS=/home/phc001/.local/share${XDG_DATA_DIRS:+:${XDG_DATA_DIRS}}
PATH=/home/phc001/tools/tmux/bin:$PATH
export LD_LIBRARY_PATH PATH

################################################################################
# Configure readline
################################################################################
bind -f ~phc001/.inputrc
bind -m emacs-standard '"\e\e": vi-editing-mode'
bind -m vi-command '"\v": emacs-editing-mode'
bind -m vi-insert '"\v": emacs-editing-mode'
bind -m vi-command '"\001": beginning-of-line'
bind -m vi-command '"\005": end-of-line'
bind -m vi-insert '"\001": beginning-of-line'
bind -m vi-insert '"\005": end-of-line'
bind -m vi-command '"\020": previous-history'
bind -m vi-command '"\016": next-history'
bind -m vi-insert '"\020": previous-history'
bind -m vi-insert '"\016": next-history'

# And a few other things
source ~phc001/.fzf.bash # Needs to come before file selector widget because it sets C-t
source /home/phc001/Repositories/github.com/philippecarphin/view-command/etc/profile.d/vc.bash
source /home/phc001/Repositories/github.com/philippecarphin/env-diff/env-diff-cmd.bash
source /home/phc001/Repositories/github.com/philippecarphin/tui-selector/file-selector-widget.bash


################################################################################
# Separate history file
################################################################################
HITSFILESIZE=-1
HISTSIZE=-1
HISTFILE=~/.eternal_bash_history_phc001
HISTTIMEFORMAT=$'\033[1;32m%Y-%m-%d \033[1;33m%H:%M:%S\033[0m '
HISTCONTROL=ignoredup:ignorespace


GIT_PS1_SHOWDIRTYSTATE=yes
GIT_PS1_SHOWUNTRACKEDFILES=yes
GIT_PS1_SHOWUPSTREAM=verbose
GIT_PS1_SHOWCONFLICTSTATE=yes
GIT_PS1_DESCRIBE_STYLE=branch
GIT_PS1_SHOWCOLORHINTS=yes
source ~phc001/.git-prompt.sh
_ps1_exit_code(){
    local code=$?
    local color
    if ((code == 0)); then color=32 ; else color=31 ; fi
    printf "\001\033[1;${color}m\002${code}\001\033[0m\002"
}
export PS1=' $(_ps1_exit_code) \001\033[1;38;5;45m\002[\h:$USER $PWD$(__git_ps1 "\001\033[0m\002 (%s)\001\033[1;38;5;45m\002")] $ \001\033[0m\002'

