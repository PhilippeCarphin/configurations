# Note, when doing 'true >&${debug_fd}', debug_fd=8, and 8 is
# not a file descriptor, bash will print
# 'bash: ${debug_fd}: bad file descriptor'
# leading me to believe that for some reason bash doesn't
# expand the variable in >&${debug_fd} but if we redo it with
# debug_fd=2 and 2 is a file descriptor, the call will succeed!
# It's just that the error message shows the unexpanded form.
#
# When using variable expansion on the left side of a redirection, we have a
# different quirky behavior:  With debug_fd=8 and 8 is not a file descriptor
# meaning that it is available to be used as the file descriptor.  But using
# the variable, we can try `exec ${debug_fd}>the_file` and it will print
# `bash: exec: 8: not found` confusing the audience.  If we simply wrote out
# `exec 8>the_file` it works, so we can use an eval but we have to be careful
# so that the redirection is part of the eval. `eval exec ${fd}>file` redirects
# ${fd} to file for the eval command.  We need `eval "exec ${fd}>file"`.
#
# But I don't care what number the FD is, all I want is an unused one and there
# is a syntax just for that
# - Finds an unused FD
# - Stores it in a variable
# - Doesn't have that weird expansior interaction that requires an eval.

# Note: ${FUNCNAME:+${FUNCNAME[0]}} is so that we only attempt to dereference
# FUNCNAME if it is set.  This way we can use this PS4 in scripts that have
# `set -o nounset`

export PS4='+ \033[35m${BASH_SOURCE[0]}\033[36m:\033[1;37m${FUNCNAME:+${FUNCNAME[0]}}\033[22;36m:\033[32m${LINENO}\033[0m '

function debug(){
    case $1 in -h|--help)
        echo "Run this command to enable xtrace (set -x) with trace output going to a file in ~/.bash_debug.d"
        echo "Use tdebug to tail -f that file in another shell."
        return 0 ;;
    esac

    local debug_dir=${HOME}/.bash_debug.d
    if ! [[ -d ${debug_dir} ]] ; then
        mkdir ${debug_dir}
    fi

    local debug_file=$(mktemp bash_debug_session_$(date +%Y-%m-%d_%H-%M)_XXX.txt --tmpdir=${debug_dir})
    ln -sf ${debug_file} ${debug_dir}/latest

    exec {BASH_XTRACEFD}>${debug_file}
    set -x
}

function tdebug(){
    tail -f ~/.bash_debug.d/latest
}

function undebug(){
    case ${BASH_XTRACEFD} in
        1|2|'') ;;
        *) exec {BASH_XTRACEFD}>&- ;;
    esac
    set +x
    unset BASH_XTRACEFD
}

ps4(){
    local funcname='${FUNCNAME:+${FUNCNAME[0]}}'
    case "$1" in
        full) PS4='+ \033[35m${BASH_SOURCE[0]}\033[36m:\033[1;37m'${funcname}'\033[22;36m:\033[32m${LINENO}\033[0m ' ;;
        short) PS4='+ \033[35m${BASH_SOURCE[0]##*/}\033[36m:\033[1;37m'${funcname}'\033[22;36m:\033[32m${LINENO}\033[0m ' ;;
        no-color) PS4='+ ${BASH_SOURCE[0]}:'${funcname}':${LINENO} -- ' ;;
        short-no-color) PS4='+ ${BASH_SOURCE[0]##*/}:'${funcname}':${LINENO} -- ' ;;
        time) if [[ ${BASH_VERSINFO[0]} < 5 ]] ; then echo "ERROR: BASH < 5 does not have \$EPOCHREALTIME" ; return 1 ; fi
              PS4=$'+ \033[35m${EPOCHREALTIME}\033[36m:\033[1;37m'${funcname}'\033[22;36m:\033[32m${LINENO}\033[36m:\033[0m ' ;;
    esac
    # Note: PS4 is normally a shell variable and is not exported but exporting
    # it is useful for doing stuff like `bash -x some-script.sh` to run a script
    # with xtrace and have it use this PS4 without needing to modify the script.
    export PS4
}
_ps4(){
    COMPREPLY=( $(compgen -W "full short no-color short-no-color time" -- "${COMP_WORDS[COMP_CWORD]}") )
}
complete -F _ps4 ps4

