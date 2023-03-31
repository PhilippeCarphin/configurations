log(){
    echo "${FUNCNAME[1]} : $@" >> ~/.log.txt
}
source ~/.bash_completion.d/_ssmuse.sh

_source(){
    local cur prev words cword
    _init_completion || return

    log "====================================="
    log "cur = ${cur}"
    log "prev = ${prev}"
    log "words = ${words}"

    if ((cword < 2)) ; then
        log "Completing first word"
        _complete_first_source_argument
    else
        _complete_args_to_sourced_file ${words[1]}
    fi
}

_complete_first_source_argument(){
    log "cur=${cur}"
    case "${cur}" in
        */*)
            # If it is a path, let the default behavior take over
            log "First arg is a path, letting default take over"
            ;;
        *)
            _complete_from_path_and_pwd
            ;;
    esac
}


_complete_from_path_and_pwd(){
    log "Completing from path and pwd"
    # log "Candidates=${candidates}"
    if shopt sourcepath >/dev/null ; then
        local path_files=$(find -L $(echo "${PATH}" | tr ':' '\n') -type f -maxdepth 1 2>/dev/null)
        local i=0
        for f in ${path_files} ; do
            # Filtering out non ASCII text files here makes it SUPER SLOW
            if [[ -n "${SOURCE_COMPLETE_EXCLUDE_EXECUTABLE}" ]] && [[ -x ${f} ]] ; then
                continue
            fi
            # Here we exclude non directories (in the case $f is a link, the
            # test with -f looks at the target of the link) so if you have a
            # link to something in $PATH, this test will not exclude it
            if [[ -f ${f} ]] ; then
                # I haven't tested it but I'm assuming that this is faster than
                # using the basename command.
                basename=${f##*/}
                # Running 'file' command on each candidate slows down the process
                # noticeably so it is important to do it only for files matching
                # the current word.
                if [[ "${basename}" == ${cur}* ]] ; then
                    if [[ "$(file -L $f)" == *ASCII* ]] ; then
                        COMPREPLY[i++]=${basename}
                    fi
                fi
            fi
        done
    fi

    #
    # Because we are doing our own completion, we need to include things from
    # the current directory
    #
    _filedir
}

_complete_args_to_sourced_file(){
    log "completing args to sourced file ${words[1]}"
    case ${1} in
        ssmuse-sh|ssmuse-csh)
            __complete_ssmuse_sh
            ;;
        r.load.dot)
            __complete_r_load_dot
            ;;
        *)
            # Let filesystem completion take over
            ;;
    esac
}
# $ . r.load.dot -h
# usage: . r.shortcut.dot [-h|--help] [--list ] [--append] [--unuse] [--nobinbump] ITEM1 ... ITEMn
# NOTES: arguments are ORDER DEPENDENT, --append is deprecated and ignored
# Special tokens recognized: InOrder NoOrder FlushSsm Prepend Append (last 2 are ignored)




complete -o default -F _source source s .
