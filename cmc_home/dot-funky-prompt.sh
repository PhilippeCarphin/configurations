#!/bin/bash

if ! source ~/.git-prompt-phil.sh 2>/dev/null ; then
    echo "ERROR : ~/.git-prompt.sh not found"
    echo "Please run 'wget https://raw.githubusercontent.com/git/git/v$(git --version | awk '{print $3}')/contrib/completion/git-prompt.sh -O ~/.git-prompt.sh' or something"
    echo "Note, the only difference is that git-prompt-phil.sh shows a red [UNTRACKED_FILES] instead of a '%' to make you dislike having untracked files"
    return 1
fi


if ! type __git_ps1 &>/dev/null ; then
    echo "$0 : ERROR, you need to figure something out to have the __git_ps1 function"
    return 1
fi

GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWUPSTREAM=verbose
GIT_PS1_SHOWCOLORHINTS=true
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWTIMESINCECOMMIT=true
PROMPT_COMMAND=my_git_ps1

funky_prompt_color_array=(
     21  27  33  39  45 # blue     --(increase-green)--> cyan
     51  50  49  48  47 # cyan     --(decrease blue)---> green
     46  82 118 154 190 # green    --(increase red)----> yellow
    226 220 214 208 202 # yellow   --(decrease green)--> red
    196 197 198 199 200 # red      --(increase blue)---> magenta
    201 165 129  93  57 # magenta  --(decrease red)----> blue
)
funky_prompt_color_index=$(( RANDOM % ${#funky_prompt_color_array[@]} ))

function print_code_rgb(){
    # Codes describing the RGB cube start at 16
    # Code - 16 can be interpreted as a number in base 6
    # where the digits are the RGB values from 0 to 5
    # with 0 representing none of that color and 5 representing
    # the maximum value for that color
    local c=$(($1 - 16))
    echo "code:$1, code-16:${c}, base6:(R:$(( code_value/36 )), G:$(( (code_value%36)/6 )), B:$(( code_value%6 )))"
}
funky_prompt_color_code=
function set_prompt_color(){
    if ! [ -z ${FUNKY_PROMPT_PAUSE_COLOR_CHANGE} ] ; then
        return
    fi
    funky_prompt_color_code="\[\033[38;5;${funky_prompt_color_array[${funky_prompt_color_index}]}m\]"
    # echo "prompt_color = ${funky_prompt_color_array[${color_index}]}"
    if ! [ -z ${FUNKY_PROMPT_PRINT_CODE} ] ; then
        print_code_rgb ${funky_prompt_color_array[${funky_prompt_color_index}]}
    fi
    funky_prompt_color_index=$(( (funky_prompt_color_index + 1) % ${#funky_prompt_color_array[@]} ))
}

function is_git_submodule(){
    submod=$(git rev-parse --show-superproject-working-tree 2>/dev/null || true) # '|| true' is to prevent making the code exit if 'errexit' is on.
    if [[ "${submod}" != "" ]] ; then
        echo "\[\033[1;42m\]SM\[\033[0m\]"
    fi
}


################################################################################
# Calls __git_ps1 which sets PS1
# Uses the 3 argument form which results in PS1=$1$(printf -- $3 $gitstring)$2
# Note only the 2 and 3 argument forms set PS1.
################################################################################
function my_git_ps1(){
    # save exit code of previous command to use in prompt
    previous_exit_code=$?

    if shopt -op xtrace >/dev/null; then
        user_had_xtrace=true
        printf "Disabling xtrace during prompt evaluation\n"
    else
        user_had_xtrace=false
    fi
    set +o xtrace

    # Color of the non-git part
    # c="\[\033[35m\]"
    set_prompt_color
    c=${funky_prompt_color_code}
    envc="\[\033[34m\]"
    nc="\[\033[0m\]"

    ps1_exit_code=$(__ps1_format_exit_code $previous_exit_code)

    # Arguments for the 3 arg form of __git_ps1
    pre="${ps1_exit_code}${c}\u@\h:$(git_pwd)${nc}"
    if [[ "$PHIL_EC_ENV" != "" ]] ; then
        pre="${pre} ${envc}[${PHIL_EC_ENV}]${nc}"
    fi
    post="${c} \\\$${nc} "
    tslc=$(git_time_since_last_commit)
    submod=$(is_git_submodule)
    gitstring_format=" (%s${tslc:+ $tslc}${submod:+ ${submod}})"


    if shopt -op errexit >/dev/null ; then
        user_had_errexit=true
    else
        user_had_errexit=false
    fi
    set +e

    __git_ps1 "${pre}" "${post}" "${gitstring_format}"

    if [[ "${user_had_errexit}" == true ]] ; then
        set -e
    fi

    if [[ "${user_had_xtrace}" == true ]] ; then
        printf "Reenabling xtrace after prompt evaluation\n"
        set -x
    fi
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
    printf " ${color}$previous_exit_code\[\033[0m\] "
}

################################################################################
# Print time since last commit in a format based on the length of time
################################################################################
git_time_since_last_commit() {
    # This checks if we are in a repo an that there is a commit
    local repo_info
    repo_info=$(git rev-parse --is-inside-work-tree 2>/dev/null)
    if [ -z "$repo_info" ] ; then
        return
    fi

    local last_commit_unix_timestamp now_unix_timestamp seconds_since_last_commit
    if ! last_commit_unix_timestamp=$(git log --pretty=format:'%at' -1 2> /dev/null) ; then
        return
    fi
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
        echo "${DAYS}days"
    elif [ "$DAYS" -gt 1 ]; then
        echo "${DAYS}d${SUB_HOURS}h${SUB_MINUTES}m"
    elif [ "$HOURS" -gt 0 ]; then
        echo "${HOURS}h${SUB_MINUTES}m"
    else
        echo "${MINUTES}m"
    fi
}

