#!/bin/bash
# echo ".bash_profile START"

if [ -z $PHILRC_BASH_PROFILE ] ; then
    # Acutal bash_profile
    source ~/.envvars
    PHILRC_BASH_PROFILE="bash_profile loaded at $(date)"
    echo "$PHILRC_BASH_PROFILE" > philconfig-log
else
    # if bash_profile has already been sourced, then this file is most likely
    # being sourced becasue TMUX has started a login shell.  In that case, we
    # want to source our bashrc
    source ~/.bashrc
    return
fi


# echo ".bash_profile END"
