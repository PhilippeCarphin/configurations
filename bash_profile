#!/bin/bash
# echo ".bash_profile START"
CONFIG_DIR=$(cd -P $(dirname $(readlink ${BASH_SOURCE[0]})) > /dev/null && pwd)
echo $CONFIG_DIR > ~/CONFIG_DIR

if [ -z $PHILRC_BASH_PROFILE ] ; then
    # Acutal bash_profile
    $CONFIG_DIR/envvars
    PHILRC_BASH_PROFILE="bash_profile_loaded_at_$(date "+%Y-%m-%d_%H%M")"
    echo "$PHILRC_BASH_PROFILE" > philconfig-log
else
    # if bash_profile has already been sourced, then this file is most likely
    # being sourced becasue TMUX has started a login shell.  In that case, we
    # want to source our bashrc
    source ~/.bashrc
    return
fi


# echo ".bash_profile END"
