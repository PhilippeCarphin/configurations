# Note, when doing 'true >&${debug_fd}', debug_fd=8, and 8 is
# not a file descriptor, bash will print
# 'bash: ${debug_fd}: bad file descriptor'
# leading me to believe that for some reason bash doesn't
# expand the variable in >&${debug_fd} but if we redo it with
# debug_fd=2 and 2 is a file descriptor, the call will succeed!
# But it's just that the error message shows the unexpanded form.

function debug(){
    if [[ "${1}" == -f ]] ; then
        # export PS4='+ [35m${BASH_SOURCE[0]}[36m:[1;39m${FUNCNAME[0]}[36m:[32m${LINENO}[36m:[0m '
        # export PS4='+ [35m${BASH_SOURCE[0]}[36m:[1;39m${FUNCNAME[0]}[22;36m:[32m${LINENO}[36m:[0m '
        export PS4='\033[1;33m+ \033[35m${BASH_SOURCE[0]}\033[36m:\033[1;39m${FUNCNAME[0]}\033[22;36m:\033[32m${LINENO}\033[36m:\033[0m '
    else
        export PS4='\033[1;33m+ \033[35m${BASH_SOURCE[0]}\033[36m:\033[32m${LINENO}\033[36m:\033[0m '
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
    eval "exec ${debug_fd}>${debug_file}"
    BASH_XTRACEFD=${debug_fd}
    set -x
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
        *) eval "exec ${BASH_XTRACEFD}>&-" ;;
    esac
    set +x
    unset BASH_XTRACEFD
}
