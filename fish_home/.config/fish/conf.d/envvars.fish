# Now I'm setting up all the environment in bash before the exec
# set -x PATH $PATH $HOME/.local/bin
# set -x CDPATH $HOME . $HOME/Documents $HOME/Documents/GitHub
# set -x PHILCONFIG $HOME/.philconfig
set -x PHILRC_SYSTEM_PATH (string split ':' $PHILRC_SYSTEM_PATH)
set -x PHILRC_MY_PATH (string split ':' $PHILRC_MY_PATH)
