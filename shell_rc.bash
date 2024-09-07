PROMPT_COMMAND=()
source $(repos -get-dir bash-powerline)/powerline.sh
source $(repos -get-dir env-diff)/env-diff-cmd.bash
source "$HOME/.philconfig/shell_lib/view-rev-file.sh"
FZF_COMPLETION_OPT="--preview 'bat --color=always {}'"
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
source ~/Repositories/github.com/philippecarphin/rust-workout-log/_workout.sh
[ -d $HOME/.bash_completion.d ] && source-dir "$HOME/.bash_completion.d"
source "$HOME/.philconfig/shell_lib/functions.sh"

case ${BASH_VERSION} in
    4*|5*)
        source /opt/homebrew/share/bash-completion/bash_completion
        source $HOME/.philconfig/shell_lib/get_make_targets.sh
        shopt -s direxpand # Merci Philippe Blain :D
        ;;
    *) printf "${BASH_SOURCE[0]}: \033[1;33mWARNING\033[0m: bash ${BASH_VERSION}\n" ;;
esac

# Should have already been set but if not
if [ -z "$STOW_DIR" ] ; then
    printf "\033[1;31mERROR\033[0m: .bashrc:$LINENO STOW_DIR not set"
fi
complete -F _gcps_complete_colon_dirs cd
complete -F _gcps_complete_colon_paths vim

alias vim='gcps_wrap_command_colon_paths vim'
alias cd='gcps_wrap_command_colon_paths cd'


configure_fs1_env(){
    # See code of __load_completion from /usr/share/bash-completion/bash_completion ...
    # It searches an array of directories that starts out as
    # Since I don't define BASH_COMPLETION_USER_DIR and XDG_DATA_HOME
    # is also not defined, dirs=(${HOME}/.local/share/bash-completion/completions).
    # 1   dirs=(${BASH_COMPLETION_USER_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/bash-completion}/completions)
    #     # Equivalently: dirs is defined following this logic:
    #     # if[[ -z ${BASH_COMPLETION_USER_DIR} ]] ; then
    #     #     dirs=(${BASH_COMPLETION_USER_DIR}/completions)
    #     # else
    #     #     if [[ -n ${XDG_DATA_HOME} ]] ; then
    #     #         dirs=(${XDG_DATA_HOME}/bash-completion/completions)
    #     #     else
    #     #         dirs=($HOME/.local/share/bash-completion/completions)
    #     #     fi
    #     # fi
    #
    #     # Add '$d/bash-completion/completions' for each dir in XDG_DATA_DIRS and /usr/local/share and /usr/share
    # 2   for dir in ${XDG_DATA_DIRS:-/usr/local/share:/usr/share};
    #         dirs+=($dir/bash-completion/completions);
    #     done
    #
    # So basically, the initialization at 1 adds
    #
    #       $HOME/.local/share/bash-completion/completions
    #
    # because BASH_COMPLETION_USER_DIR and XDG_DATA_HOME are unset.  Next, we
    # add
    #
    #       $dir/bash-completion/completions
    #
    # for d in $XDG_DATA_DIRS (colon separated list) therefore.
    #
    # To work with this system, completions should be stored in
    #
    #       <SOME_DIR>/bash-completion/completions
    #
    # and <SOME_DIR> should be added to XDG_DATA_DIRS.  In this case, I have
    # been putting completion scripts inside etc but looking at 2, it seems
    # like share would be more appropriate.
    #
    export STOW_DIR=$HOME/fs1
    XDG_DATA_DIRS=${XDG_DATA_DIRS:+${XDG_DATA_DIRS}:}${STOW_DIR}/share:${STOW_DIR}/etc
    export PACKAGE_DIR="$STOW_DIR/Cellar"
    export LD_LIBRARY_PATH="${STOW_DIR}/lib:${STOW_DIR}/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
    export PATH=${STOW_DIR}/bin${PATH:+:${PATH}}
    source-dir "$HOME/fs1/etc/bash_completion.d"
    source-dir "$HOME/fs1/etc/profile.d"

    # Prefere this not being necessary
    local phil_bash_completion_dir=$STOW_DIR/etc/bash_completion.d
    local f
    for f in $(env -i ls $phil_bash_completion_dir) ; do
        source $phil_bash_completion_dir/$f
    done
    source-dir $STOW_DIR/etc/profile.d
}
configure_fs1_env ; unset -f $_

configure_history(){
    # https://stackoverflow.com/a/19533853/5795941
    # Other contexts may truncate the history, namely some people have said that
    # history may get truncated at bash startup before these two settings have
    # taken effect.  Therefore, we set the history to unlimited size, and only
    # after doing that we set the history file to a different file.
    if [[ ${BASH_VERSION} == 4*  || ${BASH_VERSION} == 5* ]] ; then
        HISTSIZE=-1
    else
        printf "${FUNCNAME[0]}: \033[1;33mWARNING\033[0m: BASH_VERSION not 4 or 5\n"
    fi
    HISTTIMEFORMAT=$'\033[1;32m%Y-%m-%d \033[1;33m%H:%M:%S\033[0m '
    HISTFILESIZE=-1
    HISTFILE=~/.eternal_bash_history
    HISTIGNORE="rm -rf *"
    PROMPT_COMMAND+=("history -a")
}
configure_history ; unset $_

function configure_vim(){
    complete -o default -F _gcps_complete_colon_paths vim
    function vim()(
        if [[ "${USER}" == phc001 ]] && [[ $(hostname) != ppp* ]] ; then
            /usr/bin/vim -p "$@"
            return
        fi

        if [[ "${1}" == */* ]] ; then
            if ! [[ -d "${1%/*}" ]] ; then
                printf "vim(): \033[1;31mERROR\033[0m: dirname(\$1) = '${1%/*}' is not a directory\n"
                return 1
            fi
        fi

        if [[ "$#" == 0 ]] ; then
            set -- .
        fi

        #
        # Help YouCompleteMe find header files even if compile_commands.json
        # is not there.
        #
        for d in ${CMAKE_PREFIX_PATH//:/ } ; do
            C_INCLUDE_PATH=${d}/include${C_INCLUDE_PATH:+:${C_INCLUDE_PATH}}
        done

        while IFS='=' read -r -d $'\0' k v ; do
            if [[ "${k}" = *_DIR ]] ; then
                C_INCLUDE_PATH=${v}/include${C_INCLUDE_PATH:+:${C_INCLUDE_PATH}}
            fi
        done < <(env -0)
        export C_INCLUDE_PATH
        # echo "C_INCLUDE_PATH=${C_INCLUDE_PATH}"
        gcps_wrap_command_colon_paths command vim -p "$@"
    )
}
configure_vim ; unset -f $_

p.notes(){
    echo '${X@P}: The value of X passed through prompt evaluation'
    echo '${X@Q}: Quote the value of X for use as unquoted input'
    echo '${X@a}: Attributes of variable X as printed by declare -p X'
    echo '${X:_Y}: (_ is -,=,+,?): Do something if X is unset or null, but without the colon, it just checks for unset.'
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

echo-list(){
    echo ${!1} | tr -d ':' '\n'
}

p.unresolved-repodir(){
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
    local true_repo_dir
    if ! true_repo_dir=$(git rev-parse --show-toplevel 2>/dev/null) ; then
        return 1
    fi

    local candidate_inode=$(stat --format=%i ${candidate})
    local repo_inode=$(stat --format=%i ${true_repo_dir})
    if [[ ${candidate_inode} == ${repo_inode} ]] ; then
        echo ${candidate}
    else
        echo "Unresolved root '${candidate}' is not the same directory as true repo root" >&2
        echo "${true_repo_dir}"
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

rsync(){

    #
    # Normalize arguments using getopt
    #
    eval local normalized_args=($(getopt -n "" --longoptions recursive -o "ra" -- "$@" 2>/dev/null || true))

    #
    # Check if there is a '-r' in the arguments
    #
    local -i i=0
    while (( i < ${#normalized_args[@]} )) ; do
        case "${normalized_args[i]}" in
            -r|--recursive) has_r=true ;;
            --) ((i++)) ; break ;;
        esac
        ((i++))
    done

    #
    # Collect positional argumetns
    #
    local posargs=()
    while (( i < ${#normalized_args[@]} )) ; do
        posargs+=("${normalized_args[i]}")
        ((i++))
    done

    #
    # If no '-r', just do the command without checks
    #
    if ! ${has_r} ; then
        command rsync "$@"
        return
    fi

    #
    # Warn of probably unwanted situation: for example,
    #   rsync localhost:/some/path/model_data remote_host:/some/path/model_data
    # which would leave us with /some/path/model_data/model_data.
    #
    # No trailing slash on first arg means we copy first arg *into* second arg.
    if [[ "${posargs[0]}" != */ ]] ; then
        # We consider it to probably not be what the user wants if the
        # basenames of both arguments match.
        local base0=${posargs[0]##*/} # Garanteed no trailing slash
        local base1="$(basename ${posargs[1]})" # Could have a trailing slash,
                                                # basename takes care of that.
        if [[ "${base0}" == "${base1}" ]] ; then
            if [[ "${posargs[1]}" == *:* ]] ; then
                local dest_host=${posargs[1]%%:*}
            else
                local dest_host=localhost
            fi
            local location_at_dest=${posargs[1]##*:}
            echo "This will create ${location_at_dest}/${base1} on ${dest_host}"
            local answer
            read -p "are you sure you want to continue? [y/n] > " answer
            if [[ "${answer}" == "n" ]] ; then
                return 1
            fi
        fi
    fi

    command rsync "$@"
}


p.upstream_compare(){
    # Don't think I'll use this very frequently but I thought it would be
    # useful to know.
    git rev-list --count --left-right @{upstream}...HEAD
}

