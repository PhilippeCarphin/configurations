source-file $TMUX_HOME/dot-tmux.conf.base
source-file $TMUX_HOME/dot-tmux.conf.work
source-file $TMUX_HOME/dot-tmux.conf.colors.red
bind r display-message "Sourcing $TMUX_HOME/dot-tmux.conf.minimal.red" \; source-file $TMUX_HOME/dot-tmux.conf.minimal.red
