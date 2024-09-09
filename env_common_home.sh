#!/bin/bash

# NOTE: MUST BE VALID ZSH AND BASH!!!
if [[ -n $ZSH_VERSION ]] ; then
    : echo "$0 sourced by ZSH"
elif [[ -n $BASH_VERSION ]] ; then
    : echo "${BASH_SOURCE[0]} sourced by bash"
fi
if [[ ${_env_common_home_sourced} == 1 ]] ; then
    printf "\033[1;31m%s\033[0m: %s\n" "ERROR" "$0 has been sourced twice"
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

if [[ "$-" == *i* ]] ; then
    export LANG=en_US.UTF-8
    export TERM=screen-256color
fi
