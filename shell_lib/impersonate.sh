impersonate(){
    local user_dir=$(eval echo ~${1})
    shift
    if [[ -z $1 ]] ; then
        local machine=localhost
    fi

    echo ORDENV_USER_PROFILE_DIR=${user_dir}/.profile.d bash --init-file ${user_dir}/.profile -l
    ssh -t ${machine} "$@" "${remote_cmd}"
}

_impersonate(){
    local cur=${COMP_WORDS[${COMP_CWORD}]}
    case ${COMP_CWORD} in
        1)
            COMPREPLY=( $(compgen -u -- ${cur}) )
            ;;
        *)
            if ! [[ $(type -t _ssh) == function ]] ; then
                __load_completion ssh
            fi
            _ssh
            ;;
    esac
}

complete -F _impersonate impersonate

