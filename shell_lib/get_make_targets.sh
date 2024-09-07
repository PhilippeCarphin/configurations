#
# Lifted from /usr/share/bash-completion/completions/make
#
p.get-make-targets(){
    words=("$@")
    # before we check for makefiles, see if a path was specified
    # with -C/--directory
    local -a makef_dir
    for (( i=0; i < ${#words[@]}; i++ )); do
        if [[ ${words[i]} == -@(C|-directory) ]]; then
            # eval for tilde expansion
            eval makef_dir=( -C "${words[i+1]}" )
            break
        fi
    done

    # before we scan for targets, see if a Makefile name was
    # specified with -f/--file/--makefile
    local -a makef
    for (( i=0; i < ${#words[@]}; i++ )); do
        if [[ ${words[i]} == -@(f|-?(make)file) ]]; then
            # eval for tilde expansion
            eval makef=( -f "${words[i+1]}" )
            break
        fi
    done

    if [[ "$(type -t _make)" != function ]] ; then
        _completion_loader make
    fi

    #
    # shopt -po <opt> prints a command to set <opt> to its current value
    #
    local reset=$(shopt -po posix)

    #
    # 'make -npq' prints all info from parsing the makefile with potential
    # '-f somefile' or '-C somedir'.  This output is passed through a sed
    # command with sed script produced by _make_target_extract_script which
    # filters out everything except target names.
    #
    set +o posix
    LC_ALL=C make -npq __BASH_MAKE_COMPLETION__=1 "${makef_dir[@]}" "${makef[@]}" .DEFAULT 2>/dev/null \
        | command sed -nf <(_make_target_extract_script -- "${cur}") \
        | sort
    $reset
}
