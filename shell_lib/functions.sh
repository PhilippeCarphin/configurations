
#
# Since I put my gitlab access token in an environment variable, and for
# troubleshooting I often dump my environment to a file, I don't want to
# have my gitlab access token visible to anyone who looks at that file
# and I don't want to have to remember to change that files permissions
#
dots(){
    sed 's/./●/g' <<< "$1"
}

p.env(){
    env -0 | sort -z | tr '\0' '\n' \
    | grep -z -v '^BASH_FUNC_.*%%=' \
    | sed "s/^GITLAB_ACCESS_TOKEN=.*/GITLAB_ACCESS_TOKEN=$(dots "$GITLAB_ACCESS_TOKEN")/"
}


function p.set-web-proxy(){
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

function gitk(){
    command gitk --all "$@" &
}
function tig(){
    command tig --all "$@"
}

function orgman(){
    pandoc --standalone -f org -t man $1 | /usr/bin/man -l -
}

function p.myjobs()
{
    (
        _p.require_ordenv
        jobst | grep "${USER}" -n
        exec 1>/dev/null
    )
}

function p.clearjobs()
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


function p.realpath(){
    local pyfunc="${FUNCNAME[0]##p.}"
    python3 -c "import os; print(os.path.${pyfunc}('$1'))"
}

function p.normpath(){
    local pyfunc="${FUNCNAME[0]##p.}"
    python3 -c "import os; print(os.path.${pyfunc}('$1'))"
}

function p.relpath(){
    if [[ "$1" == "" ]] ; then
        echo "${FUNCNAME[0]}: ERROR: Missing argument

USAGE: ${FUNCNAME[0]} PATH [START]" >&2
        return 1
    fi
    local pyfunc="${FUNCNAME[0]##p.}"
    python3 -c "import os; print(os.path.${pyfunc}('$1', start='$2'))"
}

function vimf(){
    local directory=$1; shift
    vim -p $(find ${directory} -type f "$@")
}

function cddrw(){
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

function dump-environment-to-tmpfile(){
    local envdump_dir=$HOME/envdumps
    mkdir -p ${envdump_dir}
    local envdump_file=$(mktemp env_dump_$(TZ=America/Toronto date +%Y-%m-%d_%H:%M:%S)_XXX.txt --tmpdir=${envdump_dir})
    echo "envdump_file = ${envdump_file}" >&2
    echo "\$0 = '$0'" >> ${envdump_file}
    echo "\$@ = '$@'" >> ${envdump_file}
    command env >> ${envdump_file}
}

function xargso(){
    if [[ "${1}" == "" ]] ; then
        p.error "At least one argument must be given"
        return 1
    fi
    if [[ "${1}" == -h ]] ; then
        printf "${FUNCNAME[0]} does the equivalent of 'xargs -o' on BSD"
        printf "which is to reopen STDIN as /dev/tty in the child process\n"
        printf "This is useful to when opening an interactive application\n"
        printf "like vim\n"
        return 0
    fi
    cmd="$@ \"\$@\" </dev/tty"

    # print_args xargs sh -c "${cmd}"
    printf "===============================\n"
    print_args xargs sh -c "${cmd}"
    printf "===============================\n"
    xargs sh -c "${cmd}"
    # xargs sh -c "${cmd}" "$@"
    # this does not work :
    # xargs sh -c "$@ \"\$@\" </dev/tty"
    print_args xargs sh -c "$@ \"\$@\" </dev/tty"
}


function print_args(){
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

function p.show-vars(){
    # Show environment variables and shell variables
    (

        local abbrev=$'\033[1;33m...\033[0m'
        GLUSTER_BARRIER_OPTIONS=${abbrev}
        GLUSTER_COMMAND_TREE=${abbrev}
        GLUSTER_FINAL_LIST=${abbrev}
        GLUSTER_GEO_REPLICATION_OPTIONS=${abbrev}
        GLUSTER_GEO_REPLICATION_SUBOPTIONS=${abbrev}
        GLUSTER_PROFILE_OPTIONS=${abbrev}
        GLUSTER_QUOTA_OPTIONS=${abbrev}
        GLUSTER_TOP_OPTIONS=${abbrev}
        GLUSTER_TOP_SUBOPTIONS1=${abbrev}
        GLUSTER_TOP_SUBOPTIONS2=${abbrev}
        GLUSTER_VOLUME_OPTIONS=${abbrev}
        LS_COLORS=${abbrev}
        _xspecs=([...]="...")
        unset abbrev

        declare -p
    )
}

function show-functions(){(
    # Show all function names with definition location
    shopt -s extdebug
    local functions
    if [[ -n ${1} ]] ; then
        functions=($(declare -F 2>&1 | cut -d ' ' -f 3 | command grep "$1"))
    else
        functions=($(declare -F 2>&1 | cut -d ' ' -f 3))
    fi

    for f in "${functions[@]}" ; do
        declare -F $f
    done | awk '{printf "%c[32m%s %c[1;35m%s %c[1;33m%s%c[0m\n", 27, $1, 27, $2, 27, $3, 27}'
)}


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

make(){
    if ! [ -t 1 ] ; then
        command make "$@"
    else
        local subst
        subst+="s/error/\x1b[1;31m&\x1b[0m/g; "
        subst+="s/warning/\x1b[1;33m&\x1b[0m/g; "
        subst+="s/undefined reference/\x1b[1;35m&\x1b[0m/g; "
        subst+="s/^make.*/\x1b[1;36m&\x1b[0m/g;"
        # For debugging
        # echo "subst = '$subst'"
        (
            set -o pipefail
            CLICOLOR_FORCE=yes_please command make --no-print-directory "$@" 2>&1 | sed --unbuffered "${subst}"
        )
    fi
}

p.pr(){
    vim ~/.profile_phil
}

p.print_ps1(){
    # In "", \ is used to escape, if we want our string to contain
    # an actual backslash, we need to put \\.  Sed also interprets \
    # so to match an actual \, sed needs to receive two backslashes
    # The string needs to contain two backslashes, and to create this
    # string, we need to put four backslashes in our text file.
    bs="\\\\"
    ob="\["
    cb="\]"
    subst="s/${bs}${ob}\|${bs}${cb}//g; "
    subst+="s/${bs}h/${HOSTNAME}/;"
    subst+="s/${bs}u/${USER}/"
    printf "$(echo "$PS1" | sed "${subst}")"
    if ! [[ "${1}" = -n ]] ; then
        printf "\n"
    fi
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

function ancestor_with_basename(){
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

function cd..(){
    local ancestor=$1
    local dir
    if ! dir=$(ancestor_with_basename $ancestor) ; then
        echo "${FUNCNAME[0]}: no ancestor with basename '$ancestor'" >&2
        return 1
    fi
    printf "\033[34mcd $dir\033[0m\n"
    cd $dir
}

function p.line_range(){
    local file=$1
    local start=$2
    local end=$3
    local nb_lines=$((end - start))
    tail -n +${start} ${file} | head -n ${nb_lines}
}

function p.colonlist(){
    tr ':' '\n' | sort
}

################################################################################
# Send curl requests with headers containing the gitlab access token used to
# test API requests to gitlab.science.gc.ca or gitlab.com.
################################################################################
function glcurl(){
    local req=${1} ; shift
    curl "$@" --header "PRIVATE-TOKEN: $(cat ~/.ssh/gitlab-access-token)" https://gitlab.science.gc.ca/api/v4${req}
}

function glccurl(){
    curl --header "PRIVATE-TOKEN: $(cat ~/.ssh/gitlab-com-access-token)" https://gitlab.com/api/v4$1
}

################################################################################
# Create a directory of dot graphs from a CMake 
################################################################################
function p.dotgraph-helper(){
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
function p.clear-exp-sitestore(){
    rm -rf ~/site5/rm_hind_seas_hub/work/*
}

function xflow(){
    if ! [[ -d hub ]] && [[ -d listings ]] && [[ -L EntryModule ]] ; then
        printf "phil xflow adapter: \033[1;31mERROR\033[0m: Please run inside an experiment\n"
        return 1
    fi
    printf "\033[1;33mSetting SEQ_EXP_HOME before starting xflow because otherwise I get errors when using Right-click->Info->Evaluated node config\033[0m\n"
    SEQ_EXP_HOME=$PWD command xflow
}

function p.view_listing(){
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
function p.debugpy(){
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
    port=${port:-5678}
    cmd=(python3.8 -m debugpy --wait-for-client --listen $port "$@")
    printf "Launching waiting debugger: \033[1;32m%s\033[0m\n" "${cmd[*]}"
    "${cmd[@]}"

}

function p.org-tangle(){
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
    cmd='emacs --batch -l org --eval "(setq org-src-preserve-indentation t)" ${file} -f org-babel-tangle "$@"'
    printf "Emacs batch command : \033[1;32m%s\033[0m\n" "$(eval echo $cmd)"
    eval $cmd
}

function p.org-export(){
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
function p.crlf-to-lf(){
    local file=$1
    cmd="sed 's/^M$//' \"\$@\""
    printf "sed command: \033[1;32m%s\033[0m\n" "${cmd}"
    sed 's/
$//' "$@"
}

function p.myprocs(){
    ps -F -u "$USER"
}

function p.tcheck(){
    local nb_tmux
    nb_tmux=$(pgrep -cfau "$USER" tmux)
    local tmux_color=""
    if ((nb_tmux > 15)) ; then
        tmux_color="\033[1;31m"
    elif ((nb_tmux > 10)) ; then
        tmux_color="\033[1;33m"
    fi

    printf "${tmux_color}Number of tmux procs : %s\033[0m\n" "${nb_tmux}"
}

function p.pcheck(){
    local nb_procs
    nb_procs=$(ps -u "$USER" | wc -l)
    local proc_color=""
    if ((nb_procs > 200)) ; then
        proc_color="\033[1;31m"
    elif ((nb_procs > 150)) ; then
        proc_color="\033[1;33m"
    fi
    printf "${proc_color}Number of processes  : %s\033[0m\n" "${nb_procs}"
}

function p.check-processes(){
    p.pcheck
    p.tcheck
}

function p.unansi(){
    sed 's/\x1b\[[0-9;]*m//g' "$@"
}

function make2(){
    (
    set -o pipefail
    if ! on_compute_node ; then
        local arg
        for arg in "$@" ; do
            if [[ "${arg}" == -j* ]] ; then
                echo "You are on host ${HOSTNAME} ... you should not use '-j'.  Use 'command make $*' to bypass this function if you are sure"
                return 1
            fi
        done
    fi
    CLICOLOR_FORCE=yep command make VERBOSE=${PHIL_VERBOSE_MAKE} --no-print-directory "$@" 2>&1 | highlight.sh error "" warning "" "undefined \w*" "^make.*"
    )
}

function make(){
    if ! [ -t 1 ] ; then
        command make "$@"
    else
        local subst
        subst+="s/error/\x1b[1;31m&\x1b[0m/g; "
        subst+="s/warning/\x1b[1;33m&\x1b[0m/g; "
        subst+="s/undefined reference/\x1b[1;35m&\x1b[0m/g; "
        subst+="s/^make.*/\x1b[1;36m&\x1b[0m/g;"
        # For debugging
        # echo "subst = '$subst'"
        (
            set -o pipefail
            CLICOLOR_FORCE=yes_please command make --no-print-directory "$@" 2>&1 | sed --unbuffered "${subst}"
        )
    fi
}

function p.dusage(){
    du --max-depth=1 -h "$@" | sort -h
}

p.pgrep(){
    pgrep -u $USER -f "$@"
}

p.ps(){
    ps -f -u $USER --cols $(tput cols) | sort -k 8
}

p.pst(){
    ps f -f -u $USER
}

p.check_procs_pppn(){
    local pppn=${1}
    if ! echo ${pppn} | grep -P "(ppp5)|(ppp6)" &>/dev/null ; then
        echo "Argument 1 must be ppp5 or ppp6"
        return 1
    fi

    for node in ${pppn}login-001 ${pppn}login-002 ; do
        printf "\033[1;32mLogging in to $node\033[0m\n"
        ssh -t -J${pppn} ${node} 'ps -u phc001 -f'
    done
}

p.check_procs_all(){
    for pppn in ppp5 ppp6 ; do
        printf "\033[1;35mChecking nodes on ${pppn}\033[0m\n"
        p.check_procs_pppn ${pppn}
    done
}


################################################################################
# Acquire compute node for building and running GEM (or anything else)
################################################################################
function p.qsubi(){
    local ncpu=72
    if [[ "${1}" =~ [1-9][0-9]* ]] ; then
        ncpu=${1}
        shift
    fi
    cmd=(qsub -I -lselect=1:ncpus=80:mem=100gb "$@")
    printf "Running cmd '\033[1m%s\033[0m'\n" "${cmd[*]}"
    "${cmd[@]}"
}

function p.last-finger(){
    local epoch=$(stat --format=%X ~/.plan)
    echo "$(date --date=@${epoch}) (atime of ~/.plan (may be inacurrate))"
}
