#!/bin/bash
# echo ".bash_profile START"
export PHILCONFIG=$(cd -P $(dirname $(readlink ${BASH_SOURCE[0]})) > /dev/null && pwd)

source $PHILCONFIG/FILES/initutils


if [ -z $PHILRC_BASH_PROFILE ] ; then
    # Acutal bash_profile
    source $PHILCONFIG/FILES/envvars

    # If ssh login shell that I would like to be interactive
    # if ! [ -z "$SSH_CLIENT" ] && ! [ -z "$SSH_TTY" ] && [ -z $PHILRC_BASHRC ]; then
    # TEMPORARY SOLUTION: ALWAYS SOURCE BASHRC, (anyway it contains a check that the shell is interactive)
    if true ; then
       source ~/.bashrc
    fi
    export PHILRC_BASH_PROFILE="bash_profile_loaded_at_$(date "+%Y-%m-%d_%H%M")"
else
    echo "PHILRC_BASH_PROFILE was not empty"
    # if bash_profile has already been sourced, then this file is most likely
    # being sourced becasue TMUX has started a login shell.  In that case, we
    # want to source our bashrc
    source ~/.bashrc
    return
fi

# echo ".bash_profile END"
