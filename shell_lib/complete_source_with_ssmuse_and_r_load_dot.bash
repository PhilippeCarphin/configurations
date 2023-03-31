log(){
    echo "${FUNCNAME[1]} : $@" >> ~/.log.txt
    true
}

_source(){
    local cur prev words cword
    _init_completion || return

    if ((cword < 2)) ; then
        log "Completing first word"
        _complete_sourced_file
    else
        _complete_args_to_sourced_file ${words[1]}
    fi
}

_complete_sourced_file(){
    case "${cur}" in
        */*)
            # If it is a path, let the default behavior take over
            ;;
        *)
            if shopt sourcepath &>/dev/null && [[ "${cur}" != "" ]]; then
                # Only complete from path if at ${cur} has at least one char
                # otherwise it's too long.
                _complete_from_path
            fi
            _filedir
            ;;
    esac
}

# Complete from all files in the directories of ${PATH}.
#
# control variables:
# - SOURCE_COMPLETE_EXCLUDE_EXECUTABLE
#       non-empty: Exclude executable files
#       empty: Do not exclude files marked executable
# - SOURCE_COMPLETE_ONLY_TEXT_FILES
#       non-empty: Filter out non-text files using 'file' command.
#                  This slows down the process somewhat but if the current word
#                  has at least two letters it is not slow enough to be
#                  bothersome and with more than two letters it is hardly noticeable
#       empty: Do not filter out non-ASCII files.
#
# This is different from 'compgen -c' because it gives non-executable files and
# filters out non-ascii files.
_complete_from_path(){
    local path_files=$(IFS=':\n ' find -L ${PATH//:/ } -type f -maxdepth 1 2>/dev/null)
    local PATHX=${PATH}:
    for f in  ${PATHX//:/\/${cur}* }; do
        if [[ -n "${SOURCE_COMPLETE_EXCLUDE_EXECUTABLE}" ]] && [[ -x ${f} ]] ; then
            continue
        fi

        if ! [[ -e $f ]] ; then
            continue
        fi

        if [[ -n "${SOURCE_COMPLETE_ONLY_TEXT_FILES}" ]] && [[ "$(file -L $f)" != *ASCII* ]] ; then
            continue
        fi

        local basename=${f##*/}
        COMPREPLY+=(${basename})
    done
}

_complete_args_to_sourced_file(){
    case ${1} in
        ssmuse-sh|ssmuse-csh)
            __complete_ssmuse_sh
            ;;
        r.load.dot)
            _p.r.shortcut.dot
            ;;
        *)
            # Let filesystem completion take over
            ;;
    esac
}

_p.r.shortcut.dot()
{
    compopt -o nospace
    compopt -o filenames
    if [[ "${1}" == ./* || "${1}" == /* ]] ; then
      Liste="$(FindDottableDir ${1})"    # explicit path to directory
    else
      Liste="$(_shortcut_possibilities "${1:-[a-zA-Z0-9]}" | sed -e 's/[.]sh$//g' -e 's/[.]bndl$//' -e 's://:/:' | $(\which grep) -v '[*]$' | sort -u)"
    fi
    COMPREPLY+=(${Liste})
}
################################################################################
# Completions for ssmuse-sh and r.load.dot
################################################################################

__complete_ssmuse_sh() {
    COMPREPLY=()
    local cur="${COMP_WORDS[COMP_CWORD]}"
    if __ssmuse_sh_dash_dash_in_words ; then
        return
    fi

    option=$(__ssmuse_sh_get_current_option)
    if [[ "$option" != "" ]] ; then
        log "Calling _r.load.dot"
        _filedir
        __suggest_ssmuse_sh_args_for_option ${option}
    else
        # ssmuse-sh does not have positional arguments
        # so if we are not completing the argument to an
        # option, only suggest options
        __suggest_ssmuse_sh_options
    fi
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
        -d|-x|-f) compopt -o nospace ; COMPREPLY=($(_r.load.dot ${cur})) ;;
    esac
}

complete -o default -F _source source s .
