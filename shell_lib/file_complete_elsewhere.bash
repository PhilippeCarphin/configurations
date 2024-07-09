#
# Emulate filesystem completion behavior when completing filenames
# relative to another directory.  The trick of adding a space to the
# candidate itself comes from git-completion.bash.  I don't know why
# they do it
#
file-complete-elsewhere(){
    local elsewhere=$1
    if [[ -z ${elsewhere} ]] ; then
        elsewhere=${PWD}
    fi

    #
    # The filename option causes <TAB><TAB> to only show the last part
    # if we have 'cmd src/d' on the command line and our candidates are
    # 'src/directory' 'src/document', then <TAB><TAB> will show 'directory'
    # and 'document'.
    #
    compopt -o filenames

    #
    # If we have 'cmd src/di' and then we would have a single candidate
    # 'src/directory'.  However, because we are completing from candidates
    # in a different directory, bash/readline does not know that this is
    # a directory, it just sees a single completion candidate, and therefore
    # would add a space even though compopt -o filenames is on.
    #
    # Therefore we turn on the 'nospace' option, and we will add a space
    # to the actual completion candidate when there is only one left and it
    # is a file.
    #
    compopt -o nospace

    COMPREPLY=( $(cd ${elsewhere} ; compgen -f -- "${cur}") )
    if (( ${#COMPREPLY[@]} == 1 )) ; then
        only_candidate=${COMPREPLY[0]}
        if [[ -f ${elsewhere}/${only_candidate} ]] ; then
            COMPREPLY[0]="${only_candidate} "
            # We need to turn off 'filename' completion option otherwise
            # our space that is meant to end completion of the current
            # command line argument would be escaped with a '\' and not
            # actually end the completion.
            compopt +o filenames
        elif [[ -d ${elsewhere}/${only_candidate} ]] ; then
            # Normally with 'compopt -o filenames +o nospace', if there is
            # a single candidate and it is a directory, bash/readline adds
            # a slash by automatically and does not add a space.
            COMPREPLY[0]="${only_candidate}/"
        fi
    fi
}
