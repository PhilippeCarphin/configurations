

p.view-rev-file(){
    case "${1}" in -h|--help)
        printf "Show a file at a certain revision.  Convenience wrapper for 'git show <rev>:<file>' with powerful autocomplete which opens the file in Vim\n\n"
        printf "\t${FUNCNAME[0]} <rev> <file> [vim-args...]\n"
        printf "\t${FUNCNAME[0]} <rev>:<file>:<line>\n\n"
        printf "The one argument form is meant to take the output\n"
        printf "of a 'git grep -p <pattern> <rev>' command\n"
        return
        ;;
    esac

    if [[ "$1" == *:* ]] ; then
        local rev=${1%%:*}
        local file_line_col=${1#*:}
        local file=${file_line_col%%:*}
        local line_col=${file_line_col#*:}
        local line=${line_col%%:*}
        echo "ref=${rev}, file_line_col=${file_line_col}, file=${file}, line=${line}"
        git show ${rev}:${file} | vim -R - -c "doautocmd BufRead ${file}" +${line}
    elif (( $# >= 2 )) ; then
        local rev=$1
        local file=$2
        shift; shift

        #
        # Make path relative to repo root
        # The git show command only takes paths relative to the repo root.
        #
        local repo
        if ! repo=$(git rev-parse --show-toplevel) ; then
            return 1
        fi

        # cd -P is necessary to match with the repo root returned by
        local abspath=$(cd -P ${PWD} && pwd)/$file
        # echo "abspath=${abspath}"
        local normpath=$(python3 -c "import os; print(os.path.normpath('${abspath}'))")
        # echo "normpath=${normpath}"
        local repo_relpath=${normpath##${repo}/}
        # echo "repo_relpath=${repo_relpath}"

        local ft=${file##*.}
        case ${file} in
            *Makefile|*makefile) ft=make ;;
            CMakeLists.txt) ft=cmake ;;
        esac
        printf "Running 'git show ${rev}:${repo_relpath}'\n"

        git show ${rev}:${repo_relpath} | vim -R - -c "doautocmd BufRead ${file}" "$@"
    else
        p.error "Incorrect arguments"
        ${FUNCNAME[0]} --help
        return 1
    fi
}

_p.view-rev-file-complete-refs(){
    if ! complete -p git 1>/dev/null 2>/dev/null ; then
        __load_completion git
    fi
    #
    # Git completion is set with 'compopt -o nospace' and
    # the functions add spaces to the COMPREPLY candidates
    #
    compopt -o nospace
    compopt -o filenames
    __git_complete_refs
    if (( ${#COMPREPLY[@]} == 1 )) ; then
        compopt +o filenames
    fi
}
_p.view-rev-file-complete-files(){
    local git_repo
    if ! git_repo=$(git rev-parse --show-toplevel 2>/dev/null) ; then
        return
    fi

    local rev=${words[1]}
    local dirname="${cur%/*}/"
    # If there are no slashes,
    if [[ "${cur}" != */* ]] ; then
        dirname=""
    fi

    # Since git ls-tree doesn't produce output beginning with './',
    # when ${cur} begins with './', we add './' to compgen output and use
    # ${cur#./} to match
    local prefix
    if [[ "${cur}" == ./* ]] ; then
        prefix=(-P "./")
    fi
    local newcur=${cur#./}


    # Relative to the repo root
    # Relative to PWD, the actual function will need to to change the path
    # to one that is relative to the git repo.
    COMPREPLY=( $(compgen "${prefix[@]}" -W "$(git ls-tree --name-only ${rev} ${dirname})" -- ${newcur}) )

    #
    # Handle single candidate
    #
    compopt -o nospace
    compopt -o filenames
    if (( ${#COMPREPLY[@]} == 1 )) ; then
        only_candidate=${COMPREPLY[0]}
        if [[ -f ${only_candidate} ]] ; then
            COMPREPLY[0]="${only_candidate} "
            compopt +o filenames
            # The file may not exist if the currently checked out commit
            # does not have it.  Since we don't know if it's a directory
            # all we can do is not add the space.
        elif [[ -d ${only_candidate} ]] ; then
            COMPREPLY[0]="${only_candidate}/"
        fi
    fi
}

_p.view-rev-file(){
    local cur prev words cword
    _init_completion -n : || return

    # Complete REFs
    if (( cword == 1 )) ; then
        _p.view-rev-file-complete-refs
    else
        _p.view-rev-file-complete-files
    fi
}


complete -o bashdefault -o default -o nospace -F _p.view-rev-file p.view-rev-file
