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
# Uses the 3 argument form which results in PS1=$1$(printf -- $3 $gitstring)$2
# Note only the 2 and 3 argument forms set PS1.
################################################################################
function my_git_ps1(){
    # save exit code of previous command to use in prompt
    previous_exit_code=$?

    # Color of the non-git part
    c="\[\033[35m\]"
    nc="\[\033[0m\]"

    ps1_exit_code=$(__ps1_format_exit_code $previous_exit_code)

    # Arguments for the 3 arg form of __git_ps1
    pre="${ps1_exit_code}${c}\u@\h:$(git_pwd)${nc}"
    post="${c} \\\$${nc} "
    gitstring_format=" (%s$(git_time_since_last_commit))"

    __git_ps1 "${pre}" "${post}" "${gitstring_format}"
}

################################################################################
# Prints $PWD when outside a git repo and a shortened version of PWD when
# inside a git repo.
#
# When in a git repo, strip everything from PWD up to but excluding the
# basename of the directory that is the root of the repo:
#
# Shortens
#    /home/phc001/Repositories/gitlab.science.gc.ca/phc001/my-git-repo/a/b/c
# to
#    my-git-repo/a/b/c
################################################################################
function git_pwd() {
    if [[ $(git rev-parse --is-inside-work-tree 2>/dev/null) == true ]] ; then
        local repo_dir=$(git rev-parse --show-toplevel 2>/dev/null)
        local outer=$(basename $repo_dir)
        local inner=$(git rev-parse --show-prefix 2>/dev/null)
        echo "${outer}/${inner}"
    else
        echo '\w'
    fi
}

################################################################################
# Print an exit code supplied as an argument.
# Zero is printed in bold green, anything else is printed in bold red
################################################################################
function __ps1_format_exit_code(){
	local previous_exit_code=$1
	if [[ $previous_exit_code == 0 ]] ; then
		color="\[\033[1;32m\]"
	else
        color="\[\033[1;31m\]"
    fi
    echo " ${color}$previous_exit_code\[\033[0m\] "
}

################################################################################
# Print time since last commit in a format based on the length of time
################################################################################
git_time_since_last_commit() {
    # This checks if we are in a repo an that there is a commit
    if ! git log -n 1  > /dev/null 2>&1; then
        return
    fi
    # Don't show anything if there are no staged or unstaged changes
    if git diff --no-ext-diff --quiet && git diff --no-ext-diff --cached --quiet ; then
        return
    fi

    last_commit_unix_timestamp=$(git log --pretty=format:'%at' -1 2> /dev/null)
    now_unix_timestamp=$(date +%s)
    seconds_since_last_commit=$(($now_unix_timestamp - $last_commit_unix_timestamp))

    format_seconds $seconds_since_last_commit
}

format_seconds(){
	seconds=$1
    # Totals
    MINUTES=$(($seconds / 60))
    HOURS=$(($seconds /3600))
    # Sub-hours and sub-minutes
    seconds_per_day=$((60*60*24))
    DAYS=$(($seconds / $seconds_per_day))
    SUB_HOURS=$(( $HOURS % 24))
    SUB_MINUTES=$(( $MINUTES % 60))
    if [ "$DAYS" -gt 5 ] ; then
        echo " ${DAYS}days"
    elif [ "$DAYS" -gt 1 ]; then
        echo " ${DAYS}d${SUB_HOURS}h${SUB_MINUTES}m"
    elif [ "$HOURS" -gt 0 ]; then
        echo " ${HOURS}h${SUB_MINUTES}m"
    else
        echo " ${MINUTES}m"
    fi
}
