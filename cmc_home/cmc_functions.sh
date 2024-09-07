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
