#!/bin/bash

if ! source ~/.git-prompt.sh 2>/dev/null ; then
    echo "ERROR : ~/.git-prompt.sh not found"
    echo "Please run 'wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -O ~/.git-prompt.sh'"
    return 1
fi

GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWUPSTREAM=verbose
GIT_PS1_SHOWCOLORHINTS=true
GIT_PS1_SHOWDIRTYSTATE=true
PROMPT_COMMAND=my_git_ps1

################################################################################
# Calls __git_ps1 which sets PS1
# Uses the 3 argument form which results in PS1=$1$ ($gitstring)$2
# Note only the 2 and 3 argument forms set PS1.
################################################################################
function my_git_ps1(){

    # Color of the non-git part
    c="\[\033[35m\]"
    nc="\[\033[0m\]"

    # Arguments for the 3 arg form of __git_ps1
    pre="${c}\u@\h:\w${nc}"
    post="${c} \\\$${nc} "

    __git_ps1 "${pre}" "${post}"
}
