# Note, when doing 'true >&${debug_fd}', debug_fd=8, and 8 is
# not a file descriptor, bash will print
# 'bash: ${debug_fd}: bad file descriptor'
# leading me to believe that for some reason bash doesn't
# expand the variable in >&${debug_fd} but if we redo it with
# debug_fd=2 and 2 is a file descriptor, the call will succeed!
# But it's just that the error message shows the unexpanded form.

function debug(){

    if [[ "${1}" == -f ]] ; then
        # export PS4='+ `[35m${BASH_SOURCE[0]}\033[36m:\033[1;39m${FUNCNAME[0]}\033[36m:\033[32m${LINENO}\033[36m:\033[0m '
        # export PS4='+ `[35m${BASH_SOURCE[0]}\033[36m:\033[1;39m${FUNCNAME[0]}\033[22;36m:\033[32m${LINENO}\033[36m:\033[0m '
        export PS4='+ \033[35m${BASH_SOURCE[0]}\033[36m:\033[1;39m${FUNCNAME[0]}\033[22;36m:\033[32m${LINENO}\033[36m:\033[0m '
    else
        export PS4='+ \033[35m${BASH_SOURCE[0]}\033[36m:\033[32m${LINENO}\033[36m:\033[0m '
    fi
    local debug_fd=5
    local debug_file=$(mktemp bash_debug_session_$(date +%Y-%m-%d_%H-%M)_XXX.txt --tmpdir=${HOME}/.bash_debug.d)
    ln -sf ${debug_file} ~/.bash_debug.d/latest
    if : 2>/dev/null >&${debug_fd} || : 2>/dev/null <&${debug_fd} ; then
        echo "ERROR: The file descriptor '${debug_fd}' is already in use or is invalid" >&2
        return 1
    fi

    # This needs to be in an eval because it seems that the exec works
    # differently than in other contexts.  Without the eval, say if
    # fd=5, doing 'exec ${fd}>${file}' would fail with the message
    # 'bash: exec: 5: not found' whereas doing 'exec 5>${file}' does work.
    # Hence the eval.
    # eval "exec ${debug_fd}>${debug_file}"
    # UPDATE: On this stack overflow answer https://unix.stackexchange.com/a/669677/161630
    # I noticed that he used this syntax:
    exec {debug_fd}>${debug_file}
    # AND it works.
    BASH_XTRACEFD=${debug_fd}
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

