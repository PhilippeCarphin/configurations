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

function debug(){

    if [[ "${1}" == -f ]] ; then
        # export PS4='+ `[35m${BASH_SOURCE[0]}\033[36m:\033[1;39m${FUNCNAME[0]}\033[36m:\033[32m${LINENO}\033[36m:\033[0m '
        # export PS4='+ `[35m${BASH_SOURCE[0]}\033[36m:\033[1;39m${FUNCNAME[0]}\033[22;36m:\033[32m${LINENO}\033[36m:\033[0m '
        export PS4='+ \033[35m${BASH_SOURCE[0]}\033[36m:\033[1;39m${FUNCNAME[0]}\033[22;36m:\033[32m${LINENO}\033[36m:\033[0m '
    else
        export PS4='+ \033[35m${BASH_SOURCE[0]}\033[36m:\033[32m${LINENO}\033[36m:\033[0m '
    fi
    local debug_file=$(mktemp bash_debug_session_$(date +%Y-%m-%d_%H-%M)_XXX.txt --tmpdir=${HOME}/.bash_debug.d)
    ln -sf ${debug_file} ~/.bash_debug.d/latest

    # local debug_fd
    exec {BASH_XTRACEFD}>${debug_file}
    # BASH_XTRACEFD=${debug_fd}
    set -x
}

alias debug-reload="source ${BASH_SOURCE[0]}"

function set-debug-trap(){

    echo "UNDER CONSTRUCTION: line numbers seem wrong"
    trap '
        printf "\033[35m${BASH_SOURCE[0]}:${FUNCNAME[0]}:${BASH_LINENO[0]}\033[0m -- ${BASH_COMMAND}\n" >&2
    ' DEBUG
}

function tdebug(){
    tail -f ~/.bash_debug.d/latest
}

function cdebug(){
    cp ~/.bash_debug $1
}

function undebug(){
    case ${BASH_XTRACEFD} in
        1|2|'') ;;
        *) exec {BASH_XTRACEFD}>&- ;;
    esac
    set +x
    unset BASH_XTRACEFD
}

alias debug-trap="trap 'echo \"DEBUG: \${BASH_COMMAND}\" >&2' DEBUG"
alias return-trap="trap 'echo \"RETURN: \${FUNCNAME[0]}\" >&2' RETURN"
alias err-trap="trap 'echo \"ERR: \${BASH_SOURCE[0]}-:-\${FUNCNAME[0]}-:-\${BASH_LINENO[1]}-:-\${BASH_COMMAND}\" >&2' ERR"

function debug-traps(){
    # Doesn't seem to work.  It looks like the RETURN trap only affects this
    # function.  Using aliases instead
    while (( $# )) ; do
        case $1 in
            DEBUG|debug) trap 'echo "DEBUG: ${BASH_COMMAND}" >&2' DEBUG ; shift ;;
            RETURN|return) trap 'echo "RETURN: ${FUNCNAME[0]}" >&2' RETURN ; shift ;;
            ERR|err) trap 'echo "ERR : ${BASH_COMMAND}" >&2' ERR ; shift
        esac
    done
}

