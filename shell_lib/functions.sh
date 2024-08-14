
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
    local color_var_names
    if [[ -t stdout ]] ; then
        color_var_names=(sed -z "s/\([a-zA-Z_]\+\)=\(.*\)/\x1b[34m\1\x1b[36m=\x1b[0m\2/")
    else
        color_var_names=(cat)
    fi
    env -0 | sort -z \
    | command grep -z -v '^BASH_FUNC_.*%%=' \
    | sed -z "s/^GITLAB_ACCESS_TOKEN=.*/GITLAB_ACCESS_TOKEN=$(dots "$GITLAB_ACCESS_TOKEN")/" \
    | "${color_var_names[@]}" \
    | tr '\0' '\n'
}

# WORK
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

# WORK
function p.myjobs()
{
    jobst | grep "${USER}" -n
}

# WORK
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

# WORK-ish
p.pr(){
    vim ~/.profile_phil
}

p.print_ps1(){
    # In "", \ is used to escape, if we want our string to contain
    # an actual backslash, we need to put \\.  Sed also interprets \
    # so to match an actual \, sed needs to receive two backslashes
    # The string needs to contain two backslashes, and to create this
    # string, we need to put four backslashes in our text file.
    bs="\\\\" # Create a string that contains two backslashes
    ob="\["   # \[ which sed will interpret as the character '['
    cb="\]"   # \] which sed will interpret as the character ']'
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
# WORK
function glcurl(){
    # Keep unevaluated for printing then evaluate
    local header='PRIVATE-TOKEN: $(<~/.ssh/gitlab-access-token)'
    local url="https://gitlab.science.gc.ca/api/v4${1}"
    printf 'curl --header "%s" %s\n' "${header}" "${url}" >&2
    curl --header "$(eval echo ${header})" ${url}
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
# WORK
function p.clear-exp-sitestore(){
    rm -rf ~/site5/rm_hind_seas_hub/work/*
}

# WORK
function xflow(){
    if ! [[ -d hub ]] && [[ -d listings ]] && [[ -L EntryModule ]] ; then
        printf "phil xflow adapter: \033[1;31mERROR\033[0m: Please run inside an experiment\n"
        return 1
    fi
    printf "\033[1;33mSetting SEQ_EXP_HOME before starting xflow because otherwise I get errors when using Right-click->Info->Evaluated node config\033[0m\n"
    SEQ_EXP_HOME=$PWD command xflow
}

# WORK
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
    echo "Make sure python3 gets a 3.7+ version"
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

function p.unansi(){
    sed 's/\x1b\[[0-9;]*m//g' "$@"
}

function make(){
    if [[ -t 1 ]] ; then
        local subst
        subst+="s/error/$(tput bold)$(tput setaf 1)&$(tput sgr 0)/g; "
        subst+="s/warning/$(tput bold)$(tput setaf 3)&$(tput sgr 0)/g; "
        subst+="s/undefined reference/$(tput bold)$(tput setaf 5)&$(tput sgr 0)/g; "
        subst+="s/^make.*/$(tput bold)$(tput setaf 6)&$(tput sgr 0)/g;"
        # For debugging
        # echo "subst = '$subst'"
        (
            set -o pipefail
            CLICOLOR_FORCE=yes_please command make --no-print-directory "$@" 2>&1 | sed --unbuffered "${subst}"
        )
    else
        command make "$@"
    fi
}
function wye(){
    while read l ; do
        echo "$l" >&2
        echo "$l" >&1
    done
}

function p.dusage(){
    (
        shopt -s nullglob
    # * : All files not beginning with '.'
    # .[!.]* : Files starting with a dot, followed by not-a-dot, followed by
    #          anything.
    # ..?* : File names beginning with '..' folowed by at least one character
    #        since the previous expression excluded all files beginning with
    #        '..'
    # . : To give the total for this directory
    du -sh * .[!.]* ..?* | sort -h | python3 -c "
import sys
multiplier = { 'K': 10**3, 'M':10**6, 'G': 10**9, 'T':10**12 }
letters = {0: '', 3:'K', 6:'M', 9:'G', 12:'T'}
total_bytes = 0.0
for l in sys.stdin:
    print(l.strip())
    size, filename = l.split()
    # print(f'size: {size}, filename: {filename}')
    if size[-1] in 'KMGTP':
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

# WORK
function p.last-finger(){
    local epoch=$(stat --format=%X ~/.plan)
    echo "$(date --date=@${epoch}) (atime of ~/.plan (may be inacurrate))"
}

print_array(){
    local -n  ref=$1
    local     name=$1
    local fmt="\033[35m%s\033[0m[\033[36m%s\033[0m]='\033[32m%s\033[0m'\n"
    for k in ${!ref[@]} ; do
        printf "${fmt}" "${name}" "$k" "${ref[$k]}"
    done
}

print_list(){
    if (( $# == 2 )) ; then
        local sep=$1 ; shift
    else
        local sep=:
    fi
    local -n ref=$1

    # echo "${ref}" | tr "${sep}" "\n" | awk "{print NR\": '\"\$0\"'\"}"

    local IFS="${sep}"
    local -a elements=(${ref})
    unset IFS
    print_array elements
}

_print_array(){
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local arrays=($(compgen -A arrayvar))
    arrays+=($(declare -A | cut -d ' ' -f 3 | cut -d = -f 1))
    COMPREPLY=($(compgen -W "${arrays[*]}" -- "${cur}"))
}
complete -c _print_array print_array

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
function echo-nth-arg(){
    local n=$1
    shift
    echo "${!n}"
}

function shell_vars(){
    local _shell_vars_tmpdir
    if ! _shell_vars_tmpdir=$(mktemp -t -d shell_vars_tmpdir.XXXXXX) ; then
        return 1
    fi
    if ! compgen -v | sort >${_shell_vars_tmpdir}/all_vars.txt ; then
        return 1
    fi
    if ! compgen -e | sort >${_shell_vars_tmpdir}/env_vars.txt ; then
        return 1
    fi
    if ! compgen -A arrayvar | sort >${_shell_vars_tmpdir}/arr_vars.txt ; then
        return 1
    fi
    if ! declare -A | cut -d ' ' -f 3 | cut -d '=' -f 1 | sort > ${_shell_vars_tmpdir}/assoc_arr_vars.txt ; then
        return 1
    fi
    # BEGIN RANT
    # Very important note: -1 tells comm to SUPPRESS column 1 not to show it
    # Every time I use comm (which is not super often) I glance at the manpage
    # and see 
    # -1 ... (lines unique to file 1)
    # -2 ... (lines unique to file 2)
    # and the "unique to file 1" draws my eye and I look no further.  I know it
    # clearly says "suppress" but when writing this function and the previous
    # time I had to use comm, both times I missed it and went "unique to file 1,
    # that's what I want, comm -1 ..., why isn't it doing what I want?!"
    # END RANT
    comm -23 ${_shell_vars_tmpdir}/all_vars.txt ${_shell_vars_tmpdir}/env_vars.txt > ${_shell_vars_tmpdir}/noenv.txt
    comm -23 ${_shell_vars_tmpdir}/noenv.txt ${_shell_vars_tmpdir}/arr_vars.txt > ${_shell_vars_tmpdir}/noarr.txt
    comm -23 ${_shell_vars_tmpdir}/noarr.txt ${_shell_vars_tmpdir}/assoc_arr_vars.txt >${_shell_vars_tmpdir}/shell_vars.txt

    if [[ "${1}" == "-v" ]] ; then
        local var
        while read var ; do
            local -n val=${var}
            echo "${var}=${val[*]}"
        done < ${_shell_vars_tmpdir}/shell_vars.txt
    else
        cat ${_shell_vars_tmpdir}/shell_vars.txt
    fi
    rm -r ${_shell_vars_tmpdir}
}

function func_change(){
    local initial_funcs=$(mktemp -t initial_funcs.XXXXXX)
    compgen -A function | sort >${initial_funcs}
    local final_funcs=$(mktemp -t final_funcs.XXXXXX)
    (
        "${@}"
        compgen -A function | sort >${final_funcs}
    )
    printf "\033[1;32mNew functions:\033[0m\n"
    printf "\033[1;32m==============\033[0m\n"
    comm -23 ${final_funcs} ${initial_funcs}
    printf "\033[1;31mRemoved functions:\033[0m\n"
    printf "\033[1;31m==================\033[0m\n"
    comm -13 ${final_funcs} ${initial_funcs}
    printf "\033[1;33mKept functions\033[0m\n"
    printf "\033[1;33m==============\033[0m\n"
    comm -12 ${final_funcs} ${initial_funcs}
    rm "${final_funcs}" "${initial_funcs}"
}

function func_change_2(){
    local initial_funcs=$(mktemp -t initial_funcs.XXXXXX)
    declare -f >${initial_funcs}
    local final_funcs=$(mktemp -t final_funcs.XXXXXX)
    (
        eval "${@}"
        declare -f >${final_funcs}
    )
    python3 ~/A_CLASSER/env-diff/diff_functions.py -i ${initial_funcs} -f ${final_funcs}
    rm "${final_funcs}" "${initial_funcs}"
}

man(){
    (
        if (( COLUMNS >= 80 )) ; then
            export MANWIDTH=80
        fi
        command man --no-justification "$@"
    )
}

trace(){
    (
        set -x
        SSMUSE_XTRACE_VERBOSE=1
        eval "$@"
    )
}

complete -A function p.type

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

p.whowho(){
    who | sort | awk '{print $1}' | uniq | while read u ; do finger $u | head -n 1 ; done | sort -k 4
}


p.voir(){
    voir "$@" | sed '/   \*.*\*$/d'
}
