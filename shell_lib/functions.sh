#!/bin/bash


#
# Since I put my gitlab access token in an environment variable, and for
# troubleshooting I often dump my environment to a file, I don't want to
# have my gitlab access token visible to anyone who looks at that file
# and I don't want to have to remember to change that files permissions
#
dots(){
    sed 's/./●/g' <<< "$1"
}

p.explicit-ascii(){
    # Same value as in p.env except for the '\1' in the replacement
    local replace_ansi_with_chars='s/\x1b\(\[[0-9;]*m\)/\x1b[1;37m\\x1b\1\x1b[0m\x1b/g'
    sed -e "${replace_ansi_with_chars}"
}

p.env(){
    # Make ansi sequences into printed characters by replacing the ESCAPE
    # character \x1b with the characters '\', 'x', '1', 'b' and highlight the
    # whole sequence.  This needs to be done as the very first thing so that
    # we only do this to ansi sequences that are part of the value of a variable
    # and not to the ansi sequences added by the following substitutions.
    local replace_ansi_with_chars='s/\x1b\(\[[0-9;]*m\)/\x1b[1;37m\\x1b\1\x1b[0m\x1b\1/g'
    # Hide bash function bodies.  Needs to be done before colorizing the variable
    # names otherwise we won't have a match because there will be an ansi sequence
    # between the last '%' and the '='.  Note that we are using -z mode with
    # sed so this will match multiple lines.
    local hide_bash_func_body='s/\(BASH_FUNC_.*%%\)=.*/\1=\x1b[1;38;5;245m{...}\x1b[0m/'
    # Colorize variable names.
    local colorize_var_names='s/\([a-zA-Z_%]\+\)=\(.*\)/\x1b[34m\1\x1b[1;36m=\x1b[0m\2/'
    # Replace gitlab access token with a string of big dots of the same length
    local hide_gitlab_access_token="s/^GITLAB_ACCESS_TOKEN=.*/GITLAB_ACCESS_TOKEN=$(dots "$GITLAB_ACCESS_TOKEN")/"
    local append_sgr0='s/$/\x1b[0m/'
    if [[ $(uname) == Darwin ]] ; then
        sed=gsed
    else
        sed=sed
    fi

    if [[ -t 1 ]] ; then
        env -0 \
        | sort -z \
        | ${sed} -z -e "${replace_ansi_with_chars}" -e "${hide_bash_func_body}" \
                 -e "${colorize_var_names}" -e "${hide_gitlab_access_token}" \
                 -e "${append_sgr0}" \
        | command grep -z "$1" \
        | tr '\0' '\n'
    else
        env -0 \
        | sort -z \
        | ${sed} -z -e "${replace_ansi_with_chars}" -e "${hide_bash_func_body}" \
        | command grep -z "$1" \
        | tr '\0' '\n'
    fi
}

gitk(){
    command gitk --all "$@" &
}

orgman(){
    pandoc --standalone -f org -t man $1 | /usr/bin/man -l -
}

# WORK
p.myjobs()
{
    jobst | grep "${USER}" -n
}

# WORK
p.clearjobs()
{
    (
        for jobid in $(jobst -u $USER | grep $USER | cut -d '|' -f 1) ; do
            while jobdel ${jobid} > /dev/null 2>&1
            do
                echo "Killing job '${jobid}'" >&2
                sleep 3
            done
            echo "" >&2
            echo "Job '${jobid}' successfully killed." >&2
        done
    )
}


p.realpath(){
    local pyfunc="${FUNCNAME[0]##p.}"
    python3 -c "import os; print(os.path.${pyfunc}('$1'))"
}

p.normpath(){
    local pyfunc="${FUNCNAME[0]##p.}"
    python3 -c "import os; print(os.path.${pyfunc}('$1'))"
}

p.relpath(){
    local target=${1}
    local start=${2}
    if [[ -z ${target} ]] ; then
        printf "ERROR: missing argument TARGET\n"
        return 2
    fi
    if [[ -z ${start} ]] ; then
        printf "ERROR: missing argument START\n"
        return 2
    fi

    if [[ "${target}" != /* ]] ; then
        target=$PWD/$target
    fi

    python3 -c "import os; print(os.path.relpath('$target', start='$start'))"
}

vimf(){
    local directory=$1; shift
    vim -p $(find ${directory} -type f "$@")
}

cddrw(){
    local cmd=$1
    if ! which "${cmd}" 2>/dev/null ; then
        >&2 echo -e "Usage : ${FUNCNAME[0]} CMD

CMD must be a command"
        return 1
    fi
    local command_location
    command_location="$(dirname "$(readlink -f "$(which "${cmd}")")")"
    printf "\033[33mcd %s\033[0m\n" "${command_location}" >&2
    cd "$command_location" || return
}

dump-environment-to-tmpfile(){
    local envdump_dir=$HOME/envdumps
    mkdir -p ${envdump_dir}
    local envdump_file=$(mktemp env_dump_$(TZ=America/Toronto date +%Y-%m-%d_%H:%M:%S)_XXX.txt --tmpdir=${envdump_dir})
    echo "envdump_file = ${envdump_file}" >&2
    echo "\$0 = '$0'" >> ${envdump_file}
    echo "\$@ = '$@'" >> ${envdump_file}
    command env >> ${envdump_file}
}

xargso(){
    if [[ "${1}" == "" ]] ; then
        p.error "At least one argument must be given"
        return 1
    fi
    if [[ "${1}" == -h ]] ; then
        cat <<-EOF
			${FUNCNAME[0]} does the equivalent of 'xargs -o' on BSD"
			which is to reopen STDIN as /dev/tty in the child process\n"
			This is useful to when opening an interactive application\n"
			like vim\n"
		EOF
        return 0
    fi
    # The call is expected to be 'xargs PROG_NAME <OTHER_ARGS>'
    cmd=("$@" "\"\$@\"" "</dev/tty")
    prog_name=$1

    # print-args xargs sh -c "${cmd}"
    printf "===============================\n"
    print-args xargs sh -c "${cmd}"
    printf "===============================\n"
    xargs sh -c "${cmd[*]}" "${prog_name}"
    # xargs sh -c "${cmd}" "$@"
    # this does not work :
    # xargs sh -c "$@ \"\$@\" </dev/tty"
    print-args xargs sh -c "$@ \"\$@\" </dev/tty"
}


print-args(){
    # Useful to double check how arguments are given to a program.
    # For example, xargso above, the arguments get split /c
    local caller=${FUNCNAME[1]}
    if [[ "${caller}" == "" ]] ; then
        caller="main"
    fi
    local i=1
    echo "${caller}: \$0   = $0"
    echo "${caller}: \$#   = $#"
    echo "${caller}: args = '$@'"
    for arg in "$@" ; do
        echo "${caller}: arg[$((i++))] = $arg"
    done
}

# A date command to use in _F_ilenames
fdate(){
    date +%Y-%m-%d_%H.%M.%S
}

# List all paths that ld will search in for libraries in the current environment
p.get_ld_search_paths(){
    # ldconfig -v outputs a path followed by all shared libraries in that path
    # with a leading tab.  To get just the paths, we filter out the lines
    # beginning with a tab.
    ldconfig -v 2>/dev/null | grep -v ^$'\t'
}

p.set-title(){
    # TMUX intercepts this and stores it in #T.  Then TMUX may
    # output something for the terminal program.  To have TMUX
    # "pass it through", use
    #     set-option -g set-titles on
    #     set-option -g set-titles-string "#T"
    printf "\033]0;$*\007"
}

p.get-cursor(){
    # https://stackoverflow.com/questions/2575037/how-to-get-the-cursor-position-in-bash
    local CURPOS
    echo -en "\E[6n"
    read -sdR CURPOS
    echo ${CURPOS#*[}
}

p.cmake_asm(){
    cat <<- EOF
		If <source_dir>/<d>/CMakeLists.txt creates a target with the
		source file <source_dir>/<d>/<d2>/file.c, then going go into
		<build_dir>/<d> and run 'make <d2>/file.c.s to generate the
		assembly for file.c.  The path will be printed.  It should be
		<build_dir>/<d>/CMakeFiles/<target_name>.dir/file.c.s

		Note: Some components of <d> may change names if
		add_subdirectory(a a2) is used.  For example, if <d> = a/b/c
		in the source dir would become <d> = a2/b/c in the build_dir
		Multiple components can be replaced by a single component as
		well add_subdirectory(a/b/c e) would mean that we would need
		to go to <build_dir>/e to run 'make <d2>/file.c.s.
EOF
}

ancestor_with_basename(){
    local ancestor=$1
    local dir=$PWD
    while [[ "$(basename $dir)" != "${ancestor}" ]] ; do
        if [[ "${dir}" == "/" ]] ; then
            echo "Root reached and ancestor '${ancestor}' not found" >&2
            return 1
        fi
        dir=$(dirname $dir)
    done
    echo $dir
}

cd..(){
    local ancestor=$1
    local dir
    if ! dir=$(ancestor_with_basename $ancestor) ; then
        echo "${FUNCNAME[0]}: no ancestor with basename '$ancestor'" >&2
        return 1
    fi
    printf "\033[34mcd $dir\033[0m\n"
    cd $dir
}

p.line_range(){
    local file=$1
    local start=$2
    local end=$3
    local nb_lines=$((end - start))
    tail -n +${start} ${file} | head -n ${nb_lines}
}

p.colonlist(){
    tr ':' '\n' | sort
}

p.list-prepend(){
    local -n var=$1
    local piece=$2
    local sep=$(printf "${3:-:}")
    var=${piece}${var:+${sep}${var}}
}
_p.list-prepend(){
    case ${COMP_CWORD} in
        1)
            compopt +o default
            COMPREPLY=($(compgen -v -- "${COMP_WORDS[COMP_CWORD]}"))
            ;;
        2)
            compopt -o default
            compopt -o filenames
            ;;
        3)
            compopt +o default +o filenames
            COMPREPLY=($(compgen -W "; : \\\\n" "${COMP_WORDS[COMP_CWORD]}"))
            ;;
    esac
}
complete -F _p.list-prepend p.list-prepend

################################################################################
# Send curl requests with headers containing the gitlab access token used to
# test API requests to gitlab.science.gc.ca or gitlab.com.
################################################################################
# WORK
glcurl(){
    local request="$1" ; shift
    if [[ -z ${request} ]] ; then
        printf "${FUNCNAME[0]}: ERROR: Empty request\n"
        return 1
    fi
    if [[ ${request} != /* ]] ; then
        printf "${FUNCNAME[0]}: ERROR: Requests must start with '/' to match documentation\n"
        return 1
    fi
    if ! [[ -f ~/.ssh/gitlab-access-token ]] ; then
        printf "${FUNCNAME[0]}: ERROR: File \~/.ssh/gitlab-access-token must and be a single line containing a gitlab access token\n"
        return 1
    fi

    local header='PRIVATE-TOKEN: $(<~/.ssh/gitlab-access-token)'
    local url="https://gitlab.science.gc.ca/api/v4${request}"
    printf 'curl --header "%s" %s %s\n' "${header}" "${url}" "$*" >&2
    curl --header "$(eval echo $header)" ${url} "$@"
}

glscurl(){
    local request="$1" ; shift
    if [[ -z ${request} ]] ; then
        printf "${FUNCNAME[0]}: ERROR: Empty request\n"
        return 1
    fi
    if [[ ${request} != /* ]] ; then
        printf "${FUNCNAME[0]}: ERROR: Requests must start with '/' to match documentation\n"
        return 1
    fi
    if ! [[ -f ~/.ssh/gitlab-access-token ]] ; then
        printf "${FUNCNAME[0]}: ERROR: File \~/.ssh/gitlab-access-token must and be a single line containing a gitlab access token\n"
        return 1
    fi

    local header='PRIVATE-TOKEN: $(<~/.ssh/gitlab-stage-access-token)'
    local url="https://gitlab-stage.science.gc.ca/api/v4${request}"
    printf 'curl --header "%s" %s %s\n' "${header}" "${url}" "$*" >&2
    curl --header "$(eval echo $header)" ${url} "$@"
}

glccurl(){
    local header='PRIVATE-TOKEN: $(<~/.ssh/gitlab-com-access-token)'
    local url="https://gitlab.com/api/v4${1}" ; shift
    printf 'curl "$@" --header "%s" %s\n' "${header}" "${url}" >&2
    curl "$@" --header "$(eval echo ${header})" ${url}
}

################################################################################
# Create a directory of dot graphs from a CMake 
################################################################################
p.dotgraph-helper(){
    if [[ "$1" == "-h" ]] ; then
        cat <<- EOF
			Generate PNG files from all the GraphViz files generated by a
			\`cmake --graphviz=_\` command.

			From a project's build directory run

			    $0 OUTPUT_DIR CMAKE_SOURCE_DIR [cmake args ...]

			to obtain a directory with graphviz files and their PNG counterpart.
			EOF
    fi

    local output_dir=$1 ; shift
    local cmake_source_dir=$1 ; shift
    if [[ -f ./CMakeLists.txt ]] ; then
        echo "Error: This will run CMake in the current directory wich contains a CMakeLists.txt file"
        return 1
    fi

    if ! [[ -e ${cmake_source_dir}/CMakeLists.txt ]] ; then
        echo "Error: Second argument does not contain a CMakeLists.txt file"
        return 1
    fi

    if [[ -d "${output_dir}" ]] ; then
        echo "Error: Directory '$output_dir' already exists"
        return 1
    fi

    if ! mkdir "$output_dir" ; then
        echo "Error creating directory '$output_dir'"
        return 1
    fi

    mkdir $output_dir/dot $output_dir/png

    printf "\033[1;37mGenerating graphviz files with CMake\033[0m\n"
    local cmd=(cmake "${cmake_source_dir}" "--graphviz=$output_dir/dot/depgraph" "$@")
    echo "${cmd[*]}"
    if ! "${cmd[@]}" ; then
        echo "Error generating graphviz graphs with CMake: see above"
        return 1
    fi
    local max_len=0
    for f in $output_dir/dot/* ; do
        if (( ${#f} > max_len )) ; then
            max_len=${#f}
        fi
    done
    if (( max_len > 60 )) ; then max_len=60 ; fi

    printf "\033[1;37mGenerating PNG files from graphviz files\033[0m\n"
    for f in $output_dir/dot/* ; do
        local name=${f##*/}
        printf "dot -Tpng -o %-${max_len}s %s\n" "\"${output_dir}/png/${name}.png\"" "\"${f}\"" >&2
        cmd=(dot -Tpng -o "${output_dir}/png/${name}.png" "${f}")
        # echo "${cmd[*]}" >&2
        "${cmd[@]}"
    done
}

################################################################################
# Maestro functions
################################################################################
# WORK
p.clear-exp-sitestore(){
    rm -rf ~/site5/rm_hind_seas_hub/work/*
}

# WORK
p.view-listing(){
    local compressed_listing=$1
    if ! [[ -f "${compressed_listing}" ]] ; then
        p.error "Listing '${compressed_listing}' does not exist"
        return 1
    fi
    # Assume that mktemp always succeeds
    local tempfile=$(mktemp uncompressed_listing_XXXXXX.sh)
    gunzip -c ${compressed_listing} > ${tempfile}
    vim ${tempfile}
    if ! rm ${tempfile} ; then
        p.error "Could not remove '${tempfile}'"
    fi
}

# Documentation and shortcut for debugging with debugpy and vscode.
p.debugpy(){
    if [[ "$1" == [0-9]* ]] ; then
        local port=$1; shift
    fi
    local file=$1
    if [ -z $file ] ; then
        printf "USAGE: p.debugpy [PORT] FILE [ARGS ...]

The PORT argument is detected as a string of only digits.  Therefore this command doesn't
work if your filename is only digits but that would be weird.

Run the command and launch the corresponding configuration in VSCode.  It should look like
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    \"version\": \"0.2.0\",
    \"configurations\": [
        {
            \"name\": \"Attach\",
            \"type\": \"python\",
            \"request\": \"attach\",
            \"connect\": {
                \"host\": \"localhost\",
                \"port\": 5678
            },
            // With this setting set to false, the debugger will enter library
            // functions.  Otherwise, doing 'step into' while on a library
            // function makes us jump over the function, confusing the audience.
            \"justMyCode\": false
        }
    ]
}
\033[1;31mERROR\033[0m: No file specified\n"
        return 1
    fi
    echo "Make sure python3 gets a 3.7+ version"
    local port=${port:-5678}
    local cmd=(python3.8 -m debugpy --wait-for-client --listen $port "$@")
    printf "Launching waiting debugger: \033[1;32m%s\033[0m\n" "${cmd[*]}"
    "${cmd[@]}"

}

p.org-tangle(){
    #
    # Note where the file appears in the command.   I  tried  to
    #     emacs --batch -l org -f org-babel-tangle "$@"
    # because  it  was  simpler  but  it  did  not  work  giving
    #     wrong type argument: stringp, nil
    # so I think that the file has to be specified before  doing
    # # the -f thing.  Or rather, a filename has to have already
    # # been read before -f is seen by the command parsing code.
    #
    # The manpage for emacs says that '-l', '-f',  '--eval'  are
    # Lisp-oriented, "these options are processed in  the  order
    # encountered".
    #
    # It does not say  that  for  the  file  to  open  but  from
    # experimentation, that's what I've seen
    #
    local file=$1
    shift
    if ! [[ -f ${file} ]] ; then
        printf "\033[31mERROR\033[0m: '$file' is not a file or doesn't exist\n"
        return 1
    fi
    cmd=(emacs --batch -l org --eval "(setq org-src-preserve-indentation t)" "${file}" -f org-babel-tangle "$@")
    printf "Emacs batch command : \033[1;32m"
    printf "'%s' " "${cmd[@]}"
    printf "\033[0m\n"
    "${cmd[@]}"
}

p.org-export(){
    local export_backend
    local export_function
    case $1 in
        man)
            export_backend=ox-man
            export_function=org-man-export-to-man
            ;;
        html)
            export_backend=ox-html
            export_function=org-html-export-to-html
            ;;
        *) echo "Unknown export type '$1'"
            return 1
            ;;
    esac
    shift

    echo "export_backend=${export_backend}"
    cmd=(emacs --batch -l ~/.emacs.d/init.el -l ${export_backend} ${1} -f ${export_function})
    printf "%s\n" "${cmd[*]}"
    ${cmd[@]}

}

################################################################################
# Remove from end of line.  This function was made because
# when doing org-babel-tangle in emacs on Windows, even if the
# file is a UNIX file with LF opened through TRAMP, when tangling
# the resulting file has CRLF line endings.  Another way is to use
# the above function p.org-tangle on the UNIX system.  If however
# the emacs on that system is not the right version or is
# missing some packages, then it may only be possible to tangle
# it correctly on the Windows machine's emacs.  In that case
# this function can be used on the file after.
################################################################################
p.crlf-to-lf(){
    local file=$1
    cmd="sed 's/^M$//' \"\$@\""
    printf "sed command: \033[1;32m%s\033[0m\n" "${cmd}"
    sed 's/
$//' "$@"
}

p.unansi(){
    local repl='s/\x1b\[[0-9;]*m//g'
    if type gsed >/dev/null 2>&1 ; then
        gsed "${repl}" "$@"
    else
        sed "${repl}" "$@"
    fi
}

p.dusage(){
    (
        shopt -s nullglob
    # Geting all files except exactly '..'
    # * : All files not beginning with '.'
    # .[!.]* : All files beginning with '.' but not beginning with '..'
    # ..?* : All files beginning with '..' plus at least one character.
    exec du -sh * .[!.]* ..?* | sort -h | python3 -c "
import sys
multiplier = { 'B': 1, 'K': 10**3, 'M':10**6, 'G': 10**9, 'T':10**12 }
letters = {0: '', 3:'K', 6:'M', 9:'G', 12:'T'}
total_bytes = 0.0
for l in sys.stdin:
    print(l.strip())
    try:
        size, filename = l.split('\t', maxsplit=1)
    except ValueError as e:
        print(f'Invalid line from stdin ({l}): {e}')
        sys.exit(1)
    # print(f'size: {size}, filename: {filename}')
    if size[-1] in 'KMGTPB':
        bytes = float(size[:-1]) * multiplier.get(size[-1], 1)
    else:
        bytes = size
    total_bytes += int(bytes)
for p in [12,9,6,3]:
    if total_bytes > 10**p:
        total_str = f'{total_bytes/(10**p):.1f}{letters[p]}'
        break
else:
    total_str = str(total_bytes)
print('---------------------')
print(f'{total_str}')
"

    # Used to be `du --max-depth=1 -h | sort -h` but this didn't list regular
    # files, just directories which made it easy to miss large regular files.
    )
}

p.pgrep(){
    pgrep -u $USER -f "$@"
}

p.ps(){
    ps -f -u $USER --cols $(tput cols) "$@" | sort -k 8
}

p.pst(){
    ps f -f -u $USER
}

################################################################################
# Acquire compute node for building and running GEM (or anything else)
################################################################################
# WORK
p.qsubi(){
    local ncpu=72
    if [[ "${1}" =~ [1-9][0-9]* ]] ; then
        ncpu=${1}
        shift
    fi
    cmd=(qsub -I -lselect=1:ncpus=80:mem=150gb "$@")
    printf "Running cmd '\033[1m%s\033[0m'\n" "${cmd[*]}"
    "${cmd[@]}"
}

# WORK
p.last-finger(){
    local epoch=$(stat --format=%X ~/.plan)
    echo "$(date --date=@${epoch}) (atime of ~/.plan (may be inacurrate))"
}

print-array(){
    local -n  ref=$1
    local     name=$1
    local fmt="\033[35m%s\033[0m[\033[36m%s\033[0m]='\033[32m%s\033[0m'\n"
    if ((${#ref[@]} == 0)) ; then
        printf "Array '%s' is empty\n" ${name}
    fi
    for k in ${!ref[@]} ; do
        printf "${fmt}" "${name}" "$k" "${ref[$k]}"
    done
}
complete -A arrayvar print-array

print-list(){
    local sep=':' OPTION OPTIND=1
    while getopts 's:' OPTION "$@" ; do case $OPTION in
        s) sep=$OPTARG ;;
        *) echo "Unknown option $opt" ; return 1 ;;
    esac ; done ; shift $(( OPTIND - 1))
    if (($# < 1)) ; then
        printf "ERROR: No list name provided"
        return 1
    fi
    local -n ref=$1
    local IFS="${sep}"
    local -a elements=(${ref})
    print-array elements
}

list-remove(){
    local sep=':' OPTION OPTIND=1
    while getopts 's:' OPTION "$@" ; do case $OPTION in
        s) sep=$OPTARG ;;
        *) echo "Unknown option $opt" ; return 1 ;;
    esac ; done ; shift $(( OPTIND - 1))
    if (($# < 1)) ; then
        printf "ERROR: No list name provided"
        return 1
    fi

    local -n list=$1
    local to_remove=$2
    local IFS="${sep}"
    local in_array=(${list})

    local result_array=()
    for a in "${in_array[@]}" ; do
        if [[ "${a}" == ${to_remove} ]] ; then
            echo "${FUNCNAME[0]}: Removing '$a' from ${!list}" >&2
            continue
        fi
        result_array+=("${a}")
    done

    if [[ "${list}" == *${sep} ]] && [[ "${to_remove}" != "" ]] ; then
        result_array+=("")
    fi

    list="${result_array[*]}"
}

complete -A variable print-list

# Some functions like 'trap -p SIG' print their output in such a way that it
# can be manually copy-pasted into a shell to set the same trap:
# $ set_trap="$(trap -p exit)"
# $ trap '' exit
# $ eval "${set_trap}"
# If we want to get the actual code of the trap, we need to get the 3rd argument
# of the command stored in ${set_trap} which can be done with
# $ exit_trap="$(eval echo-nth-arg 3 "$(trap -p EXIT)")"
# An eval is required because the output of trap is meant to be run as if it
# was typed so that the code of the trap becomes exactly one argument.
echo-nth-arg(){
    local n=$1
    shift
    echo "${!n}"
}

# Linux / Darwin
man(){
    # Run man with no justification and a maximum width of 80 columns

    local cmd=(command man)

    case $(uname) in
        Linux) cmd+=(--no-justification) ;;
        Darwin) ;;
        *) echo "Unhandled OS in ${FUNCNAME[0]}" ;;
    esac

    if ((COLUMNS < 80 )) ; then
        "${cmd[@]}" "$@"
        return
    fi

    MANWIDTH=80 "${cmd[@]}" "$@"
}


complete -A function p.type


p.whowho(){
    who | sort | awk '{print $1}' | uniq | while read u ; do finger $u | head -n 1 ; done | sort -k 4
}

p.upstream_compare(){
    # Don't think I'll use this very frequently but I thought it would be
    # useful to know.
    git rev-list --count --left-right @{upstream}...HEAD
}

p.find_readable(){
    # Not really robust since it can only handle one path,
    # making this function so I remember find can do this
    # https://gitlab.science.gc.ca/CMDS/Support/-/issues/949#note_1028252
    # Find returns !0 if it encounters any problem searching and
    # this includes permission denied on any of the directories it comes
    # across.
    local dir=$1 ; shift
    find $dir ! -readable -prune "$@"
}

p.value_is_in(){
    local value="$1" ; shift
    local l
    for l in "$@"; do
        if [[ "${l}" == "${value}" ]] ; then
            return 0
        fi
    done
    return 1
}


p.unresolved-repodir(){
    local true_repo_dir
    if ! true_repo_dir=$(git rev-parse --show-toplevel 2>/dev/null) ; then
        return 1
    fi

    # Get repo root without link resolution by just doing `cd ..` until we stop
    # being inside a git repo.
    local candidate=$(
        local prev=$PWD
        while true ; do
            if ! git rev-parse --is-inside-work-tree &>/dev/null ; then
                echo "${prev}"
                return 1
            fi
            prev=$PWD
            cd ..
        done
    )

    # Ensure that the result is good by checking that the inode of the directory
    # we will print is the same as that of true_repo_dir
    local candidate_inode=$(stat --format=%i ${candidate})
    local true_repo_inode=$(stat --format=%i ${true_repo_dir})
    if [[ ${candidate_inode} == ${true_repo_inode} ]] ; then
        echo ${candidate}
    else
        echo "Unresolved root '${candidate}' is not the same directory as true repo root" >&2
        echo "${true_repo_dir}"
    fi
}

p.find_path_var(){
    local -n path_var=$1 ; shift
    # local to_find=$2
    find ${path_var//[:, ;]/ } "$@"
}
_p.find_path_var(){
    local cur prev words cword
    _init_completion || return
    echo "cword=${cword}" >> ~/.log.txt
    if ((cword > 1)) ; then
        if ! _find 2>/dev/null ; then
            __load_completion find && _find
        fi
    else
        COMPREPLY=($(compgen -v -- "${cur}"))
    fi
}
complete -F _p.find_path_var p.find_path_var
p.go-build(){
    local builds
    if ! builds=($(p.find-build)) ; then
        return 1
    fi

    case ${#builds[@]} in
        0) echo "No builds" ; return 1 ;;
        1) printf "\033[33mcd %s\n" "${builds[0]}"
           cd ${builds[0]} ; return ;;
    esac

    local -A map
    for build in "${builds[@]}" ; do
        local base=${build##*/}
        map[${base}]=${build}
    done

    local choice
    select choice in "${!map[@]}" ; do
        printf "\033[33mcd %s\n" "${map[${choice}]}"
        cd ${map[${choice}]}
        return
    done
}
alias gb=p.go-build

p.find-build(){
    local super
    if ! super=$(git superproject-root) ; then
        return 1
    fi

    while read result ; do
        echo ${result%%/CMakeCache.txt}
    done < <(find ${super} -maxdepth 2 -name CMakeCache.txt)
}
utc-to-local(){
    local date=$1 ; shift
    TZ=America/Toronto date -d "$date UTC" "$@"
}
utc-now(){
    date -u "$@"
}
local-to-utc(){
    local date=$1 ; shift
    TZ=America/Toronto date -u -d "$date EDT" "$@"
}

rsync-help(){

    local bold=$'\033[1;37m'
    local clear=$'\033[0m'
    cat <<- EOF

	Only the trailing slash on the source argument(s) makes a difference.

	These two will copy the ${bold}content${clear} of some/dir/ ${bold}into${clear}
	some/dir/ on host:

	    rsync -r some/dir/ host:some/dir
	    rsync -r some/dir/ host:some/dir/

	These two copy the ${bold}directory${clear} some/dir ${bold}into${clear} some/
	on host:

	    rsync -r some/dir host:some
	    rsync -r some/dir host:some/

	All four of the above commands will create dir on host.

	The commands

	    rsync -r some/dir host:some/dir
	    rsync -r some/dir host:some/dir/

	will leave you with some/dir/dir on host whose content will be the content
	of some/dir at the source.

	EOF
}

cmake-help(){
    cat <<-EOF
		Build an auxiliary file like assembler or preprocessor output
		- Look of the path of the .o file that gets built:
		    a/b/c/CMakeFiles/<target-name>.dir/d/e/f/file.F90.o
		- CD progressively into this path to the last directory that has a Makefile
		- Run \`make d/e/f/file.F90.s\` or \`make d/e/f/file.F90.i\` to generate
		  assembler or preprocessor output respectively.
	EOF
}

rsync(){
    #
    # Unhandled options cause error messages from getopt but we don't care, all
    # we want is to know if --recursive/-r was used and get the positional arguments.
    # The only problem is options that take arguments: the argument will be taken
    # as a posarg.  This is super unlikely and if it happens
    #
    local posargs=()
    eval local normalized_args=($(getopt -n "" --longoptions recursive -o "ra" -- "$@" 2>/dev/null || true))
    local -i i=0
    for(( ;i<${#normalized_args[@]}; i++)) ; do
        case "${normalized_args[i]}" in
            -r|--recursive) has_r=true ;;
            --) posargs=("${normalized_args[@]:$((++i))}") ; break ;;
        esac
    done

    #
    # If no '-r', just do the command without checks
    #
    if ! ${has_r} ; then
        command rsync "$@"
        return
    fi

    #
    # When there is a / at the end of the source posarg, there is no chance it
    # won't do what we want.
    #
    if [[ "${posargs[0]}" == */ ]] ; then
        command rsync "$@"
        return
    fi

    local base_src="$(basename ${posargs[0]})"
    local base_dst="$(basename ${posargs[1]})"
    if [[ "${base_src}" == "${base_dst}" ]] ; then
        echo "This will create ${posargs[1]##*:}/${base1} at the destination"
        local answer
        read -p "are you sure you want to continue? [y/n] > " answer
        if [[ "${answer}" == "n" ]] ; then
            return 1
        fi
    fi

    command rsync "$@"
}
################################################################################
# When doing
#     rsync -r /a/b/my-dir somehost:/c/d/my-dir
# where we have the same basename for both arguments we most likely want
# '/a/b/my-dir' and /c/d/my-dir to have the same *content*
################################################################################
rsync(){
    # Assume that the last two arguments are the source and destination
    local src="${@: -2:1}" # Space before '-' is necessary
    local src_base="$(basename "${src}")"
    local src_path="${src##*:}"
    local dst="${@: -1:1}" # Space before '-' is necessary
    local dst_base="$(basename "${dst}")"
    local dst_path="${dst##*:}"

    # With no trailing slash, rsync copies SRC *into* DST which surely not what
    # you want when SRC and DST have the same basenames because you want to make
    # two directories have the same content, not copy one directory into the
    # other.
    if [[ "${src}" != */ ]] \
       && [[ "${src_base}" == "${dst_base}" ]] \
       && [[ -d "${src##*:}" ]] ; then
        echo "This will create ${posargs[1]##*:}/${base1} at the destination"
        local answer
        read -p "are you sure you want to continue? [y/n] > " answer
        if [[ "${answer}" == "n" ]] ; then
            return 1
        fi
    fi

    command rsync "$@"
}

p.notes(){
    echo 'Use the mapfile builtin to read a file into an array'
    echo 'ESC C-e expands $()'
    echo '${X@P}: The value of X passed through prompt evaluation'
    echo '${X@Q}: Quote the value of X for use as unquoted input'
    echo '${X@a}: Attributes of variable X as printed by declare -p X'
    echo '${X:_Y}: (_ is -,=,+,?): Do something if X is unset or null, but without the colon, it just checks for unset.'
}

p.pytrace(){
    # https://stackoverflow.com/questions/15760381/what-is-the-python-equivalent-of-set-x-in-shell
    # ANSWER: Using python3 -m trace FILE
    local file=$1
    local restrict=$2
    local extra_args=()
    if [[ -n ${restrict} ]] ; then
        local sys_path=$(python3 -c 'import os; import sys; print(os.pathsep.join(sys.path))')
        extra_args=(--ignore-dir ${sys_path})
    fi
    python3 -m trace "${extra_args[@]}" -t ${file}
}

p.atexit(){
    eval local arr=("$(trap -p EXIT)")
    local exit_trap_code="${arr[2]}"
    printf "Trap=--%s--\n" "${exit_trap_code}"
    local new_trap_code="${exit_trap_code}
printf '\033[38;5;240m ${FUNCNAME[0]}: $*\n'
$*
printf '\033[0m'"
    trap "${new_trap_code}" EXIT
}

p.cmake(){
    cmd=(cmake .. -DCMAKE_INSTALL_PREFIX=../localinstall -DCMAKE_BUILD_TYPE=Debug -DCMAKE_VERBOSE_MAKEFILE=FALSE "$@")
    printf "%q " "${cmd[@]}"
    printf "\033[K\n"
    "${cmd[@]}"
}

# Wrapper for clj that sets a colored prompt
clj(){
  (if
     (( $# != 0 )) ; then
     command clj "$@"
     else exec command clj -M -e '(clojure.main/repl :prompt (fn [] (printf "\033[1;32m%s=>\033[0m " (ns-name *ns*))))';fi;);}

macos_theme(){
    # By running `defaults read -g`, we get results in something that looks
    # like JSON but is slightly different
    #
    # We run this while in dark mode and while in light mode
    # and diff the outputs.
    #
    # What we see is that in dark mode the key
    #
    #   AppleInterfaceStyle = "dark"
    #
    # and in light mode, that key is not there and doing
    #
    #   defaults read -g AppleInterfaceStyle
    #
    # will print `dark` in dark mode and in light mode the command will fail
    # because the key doesn't exist.
    if defaults read -g AppleInterfaceStyle &>/dev/null ; then
        echo "dark"
    else
        echo "light"
    fi
}

set_macos_theme(){
    case "${1}" in
        dark) osascript -l JavaScript -e "Application('System Events').appearancePreferences.darkMode = true" ;;
        light) osascript -l JavaScript -e "Application('System Events').appearancePreferences.darkMode = false" ;;
        *) echo "Argmuent must be either 'dark' or 'light'" ;;
    esac
}

toggle_macos_theme(){
    case "$(macos_theme)" in
        dark) set_macos_theme "light" ;;
        light) set_macos_theme "dark" ;;
        *) echo "ERROR: macos_theme() should return either light or dark"
    esac
}

macos_discord_time(){
    # -j print, don't set the time
    # -f input format has to have minutes and seconds otherwise it
    # it will use the current minute and the current second
    if [[ -n $2 ]] ; then
        timestamp=$(TZ=$2 date -j -f %H:%M:%S $1 +%s)
    else
        timestamp=$(date -j -f %H:%M:%S $1 +%s)
    fi
    echo "<t:${timestamp}:t>"
}


clip(){
    # Ref: https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h3-Operating-System-Commands
    # Won't work in all terminals
    if [[ -n $TMUX ]] ; then
        local set_clipboard="$(tmux show-option set-clipboard)"
        if [[ "${set_clipboard}" != "set-clipboard on" ]] ; then
           printf "You are inside TMUX and set-clipboard is not on.\n" >&2
           printf "Check https://github.com/tmux/tmux/wiki/Clipboard\n" >&2
           return 1
        fi
    fi
    local clip_file=${1:-}
    # man base64: with no file or when file is '-', read from stdin
    printf "\033]52;c;%s\007" "$(base64 $clip_file)"
}

jq-help(){
    cat <<-EOF
		| jq '.[2]'                    # Get object at index 2 in array
		| jq '.k1'                     # Get value of key k1
		| jq '{"k1": .k1, "k2": .k2'}' # Form an object using incoming object's values
		| jq '{k1,k2}'                 # Shorthand for above if we want to use the same key names
		| jq '.[]'                     # Turn single array of objects into stream of many objects
		| jq '.[] | {k1,k2}'           # Array of objects to stream to only selected fields
		| jq '[ .[] | {k1,k2} ]'       # Same as above but put back into an array
		| jq '[ .[] | {id, projects: ([ .projects | .[] | .web_url ])]'
		   # Input is an array of the form
		   # [
		   #   {
		   #       "id": 1234,
		   #       <PLENTY OF FIELDS>
		   #       "projects: [
		   #           {
		   #               "id": 4567,
		   #               "web_url": "https://github.com/user/project_one",
		   #               <PLENTY OF OTHER FIELDS>
		   #           },
		   #           {   "id": 8910,
		   #               "web_url": "https://github.com/user/project_two",
		   #               <PLENTY OF OTHER FIELDS>
		   #           },
		   #           <and more projects>
		   #       ]
		   #   },
		   #   <and more elemnts>
		   # ]
		   #
		   # Unwrap array, for each item, keep the 'id' field and for the project
		   # key, the value should be the array formed by unwrapping the value
		   # of the project key, and for each project, taking the value of the
		   # web_url key.  The final object is an array of objects with a field
		   # ID, and a key "projects" whose value is an array of URLs.
		   # [
		   #     {
		   #       "id": 1234,
		   #       "projects": [
		   #           "https://github.com/user/project_one",
		   #           "https://github.com/user/project_two",
		   #           <and more project URL's>
		   #       ]
		   #     }
		   #     <and more elements>
		   # ]
	EOF
}

# Remove PWD from PATH
# - Remove empty elements (leading, trailing, or double colon)
# - Elements equal to '.'
nopwdpath(){
    local -n varname=${1:-PATH}
    local IFS=${2:-:}
    local newpath=()
    for p in ${varname} ; do
        case "${p}" in
            ""|.) continue ;;
            *) newpath+=("${p}") ;;
        esac
    done
    varname="${newpath[*]}"
}


# Do `rm -rf ./*` but only if the current directory starts with `build`.  This
# is for deleting CMake build directories and ensuring I don't delete other
# things which has happened to me many times.
rmb(){
    (
        set -o errexit -o nounset -o errtrace -o pipefail
        shopt -s inherit_errexit

        local directory_to_empty
        if ! directory_to_empty=$(builtin pwd -P) ; then
            echo "${FUNCNAME[0]}: ERROR: Cannot get current directory"
            exit 1
        fi

        if [[ -z "${directory_to_empty}" ]] ; then
            echo "${FUNCNAME[0]}: ERROR: Empty variable: directory_to_empty"
            exit 1
        fi

        if [[ $(basename "$directory_to_empty") != build* ]] ; then
            echo "${FUNCNAME[0]}: ERROR: You are not in a directory whose name starts with 'build'"
            exit 1
        fi

        local answer
        builtin read -p "${FUNCNAME[0]}: Running 'rm -rf ${directory_to_empty}/*', are you sure [y/n]> " answer
        if [[ ${answer} == y ]] ; then
            rm -rf "${directory_to_empty}"/*
        else
            exit 1
        fi
    )
}
print-seconds(){
    local seconds=$1
    local hours=$((seconds/3600))
    local minutes=$((seconds%3600/60))
    local seconds=$((seconds%60))
    if ((hours > 0)) ; then
        printf "%dh" ${hours}
        if ((minutes > 0)) ; then
            printf %02dm ${minutes}
            if ((seconds > 0)) ; then
                printf %02ds ${seconds}
            fi
        else
            if ((seconds > 0)) ; then
                printf 00m%02ds ${seconds}
            fi
        fi
    else
        if ((minutes > 0 )) ; then
            printf %dm ${minutes}
            if ((seconds > 0)) ; then
                printf %02ds ${seconds}
            fi
        else
            printf %d ${seconds}
        fi
    fi
    printf $'\n'
}

find1(){
    local dir=$1 ; shift
    find -L "$dir" -mindepth 1 -maxdepth 1 "$@"
}

findbl(){
    local dir=$1 ; shift
    find "${dir}" -type l "$@" | while read l ; do
        if ! [[ -e $l ]] ; then
            echo "${l}"
        fi
    done
}

ssh-key-signature(){
    ssh-keygen -lf "$@"
}

tree(){
    # Some spaces in the output of tree are not real spaces but rather \xa0
    # which emacs displays in a special way which is annoying when including
    # the output of tree in a text file.
    # Note: Those spaces are actually `\xc2,\xa0` or `\xa0c2` but the following
    #     command tree -C "$@" | tr '\xa0' ' '
    # works but this would probably be more accurate.  I'm not sure.
    command tree -C "$@" | sed 's/\xc2\xa0/ /g'
}

pandoc(){
    cmd=(pandoc -s)
    echo "doing '${cmd[*]} \"$@\"' because I always forget the '-s'" >&2
    command "${cmd[@]}" "$@"
}

# the real converts between datestamps like 20250928033020 (2025-09-28 03:30:00)
# and converts it to an int that's something like the number of half hours since the epoch or something
r.date(){
    case "${1:-}" in
        "") echo "function ${FUNCNAME[0]}: An argument is required" ; return 1 ;;
    esac
    local in=${1#=}
    local out=""

    if (( ${in:0:1} >= 3 )) || [[ ${1} == '='* ]] ; then
        # First digit >= 3 means it's a timestamp for me because I won't be
        # doing anything in the year 3000 or it is for sure a stamp if it
        # starts with '='.
        out=$(command r.date =${in})
        printf "%s-%s-%s.%s:%s:%s\n" \
            "${out:0:4}" "${out:4:2}" "${out:6:2}" \
            "${out:8:2}" "${out:10:2}" "${out:12:2}"
    else
        # Otherwise assume it's a date like 2021-12-01.003000 with or
        # without '-',':','.'
        out=$(command r.date ${in//[-.: ]})
        printf "%s\n" "${out}"
    fi
}


cmakeh(){
    cmake --help-command $1 | less
}
_cmakeh(){
    COMPREPLY=($(compgen -W "$(cmake --help-command-list)" -- "${COMP_WORDS[COMP_CWORD]}"))
}
complete -F _cmakeh cmakeh
cmakehm(){
    cmake --help-module $1 | less
}
_cmakehm(){
    COMPREPLY=($(compgen -W "$(cmake --help-module-list)" -- "${COMP_WORDS[COMP_CWORD]}"))
}
complete -F _cmakehm cmakehm


ldaps(){
    case "${1}" in -h|--help)
        echo "${FUNCNAME[0]} PROP=VALUE [PROP=VALUE...] [DISPLAY_PROP...]" ; return 0 ;;
    esac

    local filter="(&"
    while [[ "$1" == *=* ]] ; do
        filter+="(${1%%=*}=*${1#*=}*)" ; shift
    done
    filter+=")"

    local cmd=(ldapsearch -xLLL "${filter}" "$@")
    printf "filter='${filter}'\n"
    printf "cmd: " ; declare -p cmd
    "${cmd[@]}"
}

finger(){
    ldapsearch -xLLL "(|(cn=*${1}*)(uid=*${1}*))" cn uid mail loginShell
}

_killu(){
    local cur prev words cword
    _init_completion || return

    case $prev in
        -s) _signals ; return ;;
        -l) return ;;
    esac

    if (( cword == 1 )) && [[ "$cur" == -* ]] ; then
        _signals -
        COMPREPLY+=( $(compgen -W "-s -l" -- "$cur") )
    else
        #COMPREPLY=( $(compgen -W '$(pgrep -u $USER)' -- "$cur") )
        _psu
    fi
}
complete -F _killu kill
psu(){
    ps -au $USER
}
_psu(){
    COMPREPLY=( $(compgen -W '$(pgrep -u $USER)' -- "${COMP_WORDS[COMP_CWORD]}") )
}
complete -F _psu psu

pycalc(){
    python3 -c "print($*)"
}

cringe(){
    if ! cowthink "cringe" 2>/dev/null ; then
		cat <<-\EOF
			 ________
			( cringe )
			 --------
			        o   ^__^
			         o  (oo)\_______
			            (__)\       )\/\
			                ||----w |
			                ||     ||
		EOF
    fi
}

semver-lt(){
    case $1 in -h|--help)
        printf "${FUNCNAME[0]} A B\nsuccess if A <= B\n"
        return 0 ;;
    esac
    local -a va=(${1//./ })
    local -a vb=(${2//./ })
    local i
    for((i=0; i<=${#va[@]};i++)); do
        if (( va[i] != vb[i] )) ; then
            ((va[i] < vb[i])) ; return
        fi
    done
    # Versions are equal or effectively equal (5.2 == 5.2.0)
    return 1
}

bash-check(){
    local i v=(${1//./ })
    for((i=0;i<${#v[@]};i++)) ; do
        if ((v[i] < BASH_VERSINFO[i] )) ; then
            return 1
        fi
    done
    return 0
}

tui-jobsel(){
    local user="${1:-$USER}"
    local qjobs=($(qselect -u "${user}"))
    if (( ${#qjobs} == 0 )) ; then
        printf "No jobs for user '$USER'\n" >&2
        return 0
    fi

    local code=$(cat <<-EOF
		import json
		import sys
		j = json.load(sys.stdin)
		jobs = j['Jobs']
		for k,v in jobs.items():
		    print(f"{k} {v['job_state']} {v['Job_Name']}")
	EOF
    )
    qstat -f -F json "${qjobs[@]}" | python3 -c "${code}" | tui-selector
}

tui-jobdel(){
    set -x
    local job
    job=$(tui-jobsel $1)
    if [[ -n "${job}" ]] ; then
        qdel "${job}"
    fi
    set +x
}

fpselect(){
    local user=${1:-$USER}
    local pid=$(pgrep -u $user "$@" | xargs -r ps -f | fzf --header-lines=1 | awk '{print $2}')
    if [[ -z ${pid} ]] ; then
        return 1
    fi
    echo ${pid}
}

fkill(){
    local pid
    if pid=$(fpselect) ; then
        kill "$@" ${pid}
    fi
}

fgdb(){
    local pid
    if pid=$(fpselect) ; then
        gdb -q -tui -p ${pid}
    fi
}

fqstaty(){
    # Give FZF a command to run on the currently selected line to show
    # in the preview window.
    qstat -w "$@" \
         | fzf \
            --header-lines=2 \
            --preview="echo '{}' | awk '{print \$1}' | xargs qstat -f -F json" \
         | awk '{print $1}'
}

fqdel(){
    local jobid=$(fqstat "$@")
    if [[ -n ${jobid} ]] ; then
        qdel ${jobid}
    fi
}

fqstat(){
    local header_lines=2
    local a
    # Header is different when -u is used
    for a in "$@" ; do if [[ $a == -u ]] ; then header_lines=5 ; fi ; done
    qstat -w "$@" | fzf \
        --header-lines=${header_lines} \
        --preview-window=right,40%,wrap \
        --preview="echo '{}' | awk '{print \$1}' | xargs qstat -f -F json | jq --color-output ' .Jobs | .[]'"
}

fll(){
    local dir=${1:-}
    dir=${dir%/}
    local result
    if ! result=$(ls -lhrt ${dir} | fzf | awk '{print $9}') ; then
        return 1
    fi
    echo "${dir:+${dir}/}${result}"
}

fldap(){
    getent passwd | \
        fzf \
            --preview="echo '{}' | awk -F : '{print \$1}' | xargs -I UID ldapsearch -xLLL uid=UID | sed 's/\(.*\):\(.*\)/\x1b[1;34m\1\x1b[37m:\x1b[0;32m\2\x1b[0m/'" \
            --preview-window=right,40%,wrap
}


fqdel(){
    local j=$(fqstat "$@" | awk '{print $1}')
    if [[ -n $j ]] ; then
        echo "qdel $j"
        qdel $j
    fi
}


_qdel(){
    sc=$HOME/Repositories/github.com/philippecarphin/tests/BASH_tests/fancy_completion/square_choices.sh
    if true || [[ -n ${FANCY_COMPLETION} ]] ; then
        res=$($sc $(qselect -u anb007))
        printf "\033[A\r%s%s" "${PS1@P}" "${COMP_LINE}"
        COMPREPLY=($res)
        return
    fi
    if (( BASH_VERSINFO[0] >= 5 && BASH_VERSINFO[1] >= 3 )) ; then
        compgen -V COMPREPLY -W "$(qselect -u anb007)" -- "${COMP_WORDS[COMP_CWORD]}"
    else
        COMPREPLY=($(compgen -W "$(qselect -u anb007)" -- "${COMP_WORDS[COMP_CWORD]}"))
    fi
}

sshpwd(){
    ssh localhost -t "cd $PWD ; bash -l"
}

if-ok(){
    if (( $? == 0 )) ; then
        "$@"
    else
        printf "Previous command failed, not running '%s'\n" "$*" >&2
    fi
}

complete -F _qdel qdel

