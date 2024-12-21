#!/bin/bash

# NOTE: MUST BE VALID ZSH AND BASH!!!
if [[ -n $ZSH_VERSION ]] ; then
    this_file=$0
    # echo "$0 sourced by ZSH"
elif [[ -n $BASH_VERSION ]] ; then
    # echo "${BASH_SOURCE[0]} sourced by bash"
    this_file=${BASH_SOURCE[0]}
fi
if [[ ${_env_common_home_sourced} == 1 ]] ; then
    printf "\033[1;33m%s\033[0m: %s\n" "WARNING" "$this_file has already been sourced at least once"
fi
_env_common_home_sourced=1

export CLICOLOR=true
export PATH=$HOME/go/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export CLICOLOR_FORCE=true
export EDITOR=vim
export CMAKE_EXPORT_COMPILE_COMMANDS=TRUE

export LESS_TERMCAP_mb=$'\e[1;34m'
export LESS_TERMCAP_md=$'\e[1;36m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[0;7m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

export PATH

export STOW_DIR=$HOME/fs1

# Controls sorting
export LANG=en_US.UTF-8
export LC_COLLATE=C
export LC_ADDRESS=en_CA.UTF-8
export LC_TIME=en_CA.UTF-8

# TERM should probably be set by whatever is launching shells, not by
# a startup file that has no idea what terminal emulator the shell
# is running in.
# echo "${this_file}: TERM=${TERM}" >&2
# if [[ "$-" == *i* ]] ; then
#     export TERM=screen-256color
# fi
