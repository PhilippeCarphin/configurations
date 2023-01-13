
__complete_ssmuse_sh() {
    COMPREPLY=()
    local cur="${COMP_WORDS[COMP_CWORD]}"
    if __ssmuse_sh_dash_dash_in_words ; then
        return
    fi

    option=$(__ssmuse_sh_get_current_option)
    if [[ "$option" != "" ]] ; then
        __suggest_ssmuse_sh_args_for_option ${option}
    else
        # ssmuse-sh does not have positional arguments
        # so if we are not completing the argument to an
        # option, only suggest options
        __suggest_ssmuse_sh_options
    fi
}

__complete_r_load_dot(){

    COMPREPLY=()
    local cur prev words cword
    _get_comp_words_by_ref cur prev words cword

    if __ssmuse_sh_dash_dash_in_words ; then
        return
    fi

    option=$(__ssmuse_sh_get_current_option)
    if [[ -n ${option} ]] && __r_load_dot_option_takes_argument ${option} ; then
        __suggest_r_load_dot_args_for_option ${option}
    else
        __suggest_ssmuse_sh_packages
        __suggest_r_load_dot_options
    fi
    echo "COMPREPLY=${COMPREPLY[@]}" >> ~/.log.txt
}

__r_load_dot_option_takes_argument(){
    # No options take arguments but we would return 0
    # for those options if they existed
    case ${1} in
        --append|--list|--unuse|--help|-h) return 1 ;;
        *) return 1 ;;
    esac
}

__suggest_r_load_dot_args_for_option(){
    case "${1}" in
        -h|--help) ;; # No args for this option
        --list) ;;
    esac
}

__suggest_r_load_dot_options(){
    echo "${FUNCNAME[0]}: cur=${cur}" >> ~/.log.txt
    COMPREPLY+=($(compgen -W "-h --help --list --append --unuse --nobinbump" -- ${cur}))
}


__ssmuse_sh_dash_dash_in_words(){
    for ((i=0;i<COMP_CWORD-1;i++)) ; do
        w=${COMP_WORDS[$i]}
        if [[ "$w" == "--" ]] ; then
            return 0
        fi
    done
    return 1
}

__ssmuse_sh_get_current_option(){
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    if [[ "$prev" == -* ]] ; then
        echo "$prev"
    fi
}

__suggest_ssmuse_sh_options(){
    COMPREPLY=($(compgen -W " -d -x -f" -- ${cur}))
}

__suggest_ssmuse_sh_args_for_option(){
    case "$1" in
        -d|-x|-f) __suggest_ssmuse_sh_packages ;;
    esac
}

__suggest_bases(){
    compopt -o nospace
    COMPREPLY+=($(compgen -W "comm/ eccc/ hpci/ hpco/ hpcs/ main/ sys/ cmd/ cmo/ crd/ isst/ mrd/" -- ${cur}))
}

__suggest_ssmuse_sh_packages(){
    #
    # If it's an absolute path or a relative path
    # let default file completion handle it
    #
    compopt -o filenames
    if [[ "${cur}" == /* ]] || [[ "${cur}" == .* ]] ; then
        return
    fi

    case ${cur} in
        comm/*|eccc/*|hpci/*|hpco/*|hpcs/*|main/*|sys/*)
            compopt -o nospace
            COMPREPLY[0]="/fs/ssm/${cur}"
            ;;
        cmd/*|cmo/*|crd/*|isst/*|mrd/*)
            compopt -o nospace
            COMPREPLY[0]="/fs/ssm/eccc/${cur}"
            ;;
        *)
            __suggest_bases
            ;;
    esac
}
