#!/bin/bash

p.do-login-nodes(){
    local reset_pipefail=$(shopt -po pipefail)
    set -o pipefail
    local interactive=false
    local login=""
    local quiet=false
    local -a posargs=()
    while (($# > 0)) ; do
        case $1 in
            --interactive) interactive=true ; shift ;;
            --login) login=--login ; shift ;;
            --quiet) quiet=true ; shift ;;
            --) shift ; posargs+=("$@") ; break ;;
            *) posargs+=("$1") ; shift ;;
        esac
    done

    local -A statuses
    for i in 5 6 ; do
        for j in 1 2 3 ; do
            if ${interactive} ; then
                ssh -t -J ppp${i} ppp${i}login-00${j} "eval echo ${posargs[@]} | bash ${login} -i" \
                    | grep -v '^Warning: Permanently added .*to the list of known hosts.$'
            else
                ${quiet} || printf "\033[1;32m==> \033[1;37mDoing node '%s'\033[0m\n" ppp${i}login-00${j}
                ${quiet} || echo "$ ${posargs[*]}"
                if ${quiet} ; then
                    ssh -t -J ppp${i} ppp${i}login-00${j} echo "${posargs[*]}" \| bash ${login} &>/dev/null
                    statuses[ppp${i}login${j}]=$?
                else
                    ssh -t -J ppp${i} ppp${i}login-00${j} echo "${posargs[*]}" \| bash ${login} \
                        |& command grep -v '^Warning: Permanently added .*to the list of known hosts\..\?$'
                    local status=$?
                    if ((status == 0)) ; then
                        printf "\033[1;34m  --> \033[1;32m${status}\033[0m\n"
                    else
                        printf "\033[1;34m  --> \033[1;31m${status}\033[0m\n"
                    fi
                fi
            fi
        done
    done
    ${reset_pipefail}
}

p.app-log-level(){
    if [[ -z "${1:-}" ]] ; then
        printf "${FUNCNAME[0]}: \033[1;31mERROR\033[0m: One argument is required\n"
        return 1
    fi

    local level="${1}"
    local app_log_levels=(ALWAYS FATAL SYSTEM ERROR WARNING INFO TRIVIAL DEBUG EXTRA QUIET)
    if ! p.value_is_in "${level^^}" "${app_log_levels[@]}" ; then
        printf "${FUNCNAME[0]}: \033[1;31mERROR\033[0m: log level must be one of (${app_log_levels[*]})\n"
        return 1
    fi

    local cmd=(export APP_VERBOSE=${1})
    printf "\033[33m%s\033[0m\n" "${cmd[*]}"
    "${cmd[@]}"
}

_p.app-log-level(){
    if (( COMP_CWORD > 1 )) ; then
        return 0
    fi
    local cur=${COMP_WORDS[COMP_CWORD]}
    local app_log_levels=(ALWAYS FATAL SYSTEM ERROR WARNING INFO TRIVIAL DEBUG EXTRA QUIET)
    COMPREPLY=()
    local x
    for x in "${app_log_levels[@]}" ; do
        if [[ "${x}" == "${cur^^}"* ]] ; then
            COMPREPLY+=("${x}")
        fi
    done
}
complete -F _p.app-log-level p.app-log-level

p.prepend(){
    local -n var=$1 ; shift
    local IFS=:
    var="$*${var:+:${var}}"
}
_p.prepend(){
    local cur=${COMP_WORDS[COMP_CWORD]}
    if (( COMP_CWORD > 1 )) ; then
        compopt -o default
        return 0
    fi
    COMPREPLY=($(compgen -v -- "${cur}"))
}
complete -F _p.prepend p.prepend


# I always forget whether it's SSMUSE_VERBOSE_XTRACE or SSMUSE_XTRACE_VERBOSE
# plus ssmuse-sh checks if the value is == 1, not empty vs non-empty which would
# be more standard.  Every time, it took me like 3 tries to get it so I made
# this function.
p.verbose_ssm(){
    export SSMUSE_XTRACE_VERBOSE=1
}

trace(){
    (
        set -x
        SSMUSE_XTRACE_VERBOSE=1
        eval "$@"
    )
}

# WORK
p.set-web-proxy(){
    # From ~sbf000/.profile.d/interactive/post
    # except that I he had https_proxy=http://  and HTTPS_PROXY=http://
    # and I did            https_proxy=https:// and HTTPS_PROXY=https://
    # EDIT: Turns out my extra 's' at the end was making
    # things not work.
    local p=http://webproxy.science.gc.ca:8888/
    export http_proxy=${p}
    export https_proxy=${p}
    export HTTP_PROXY=${p}
    export HTTPS_PROXY=${p}
}


p.voir(){
    voir "$@" | sed '/   \*.*\*$/d'
}

