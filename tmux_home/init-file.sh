source /etc/profile
source ~/.profile
PATH=/home/phc001/tools/tmux/bin:$PATH

source /home/phc001/Repositories/github.com/philippecarphin/view-command/etc/profile.d/vc.bash
source /home/phc001/Repositories/github.com/philippecarphin/tui-selector/file-selector-widget.bash

HITSFILESIZE=-1
HISTSIZE=-1
HISTFILE=~/.eternal_bash_history_phc001
HISTTIMEFORMAT=$'\033[1;32m%Y-%m-%d \033[1;33m%H:%M:%S\033[0m '
HISTCONTROL=ignoredup:ignorespace

PATH=/home/phc001/fs1/bin:$PATH
LD_LIBRARY_PATH=/home/phc001/fs1/lib:${LD_LIBRARY_PATH}

export LD_LIBRARY_PATH PATH
