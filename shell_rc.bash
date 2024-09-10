PROMPT_COMMAND=()
shell_rc.bash.main(){

    source $HOME/Repositories/github.com/philippecarphin/bash-powerline/powerline.sh
    source "$HOME/.philconfig/shell_lib/view-rev-file.sh"
    FZF_COMPLETION_OPT="--preview 'bat --color=always {}'"
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash
    [ -d $HOME/.bash_completion.d ] && source-dir "$HOME/.bash_completion.d"
    source "$HOME/.philconfig/shell_lib/functions.sh"

    case ${BASH_VERSION} in
        4*|5*)
            source $HOME/.philconfig/shell_lib/get_make_targets.sh
            source $HOME/Repositories/github.com/philippecarphin/env-diff/env-diff-cmd.bash
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
    alias zsh="NORMAL_MODE=1 PS4=$'+ \033[35m%N\033[0m:\033[32m%i\033[0m ' zsh"
    configure_fs1_env ; unset -f $_
    configure_history ; unset -f $_
    configure_vim ; unset -f $_
}


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

shell_rc.bash.main ; unset -f $_

