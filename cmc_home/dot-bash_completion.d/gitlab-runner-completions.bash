#!/bin/bash


# This is the function that will be called when we press TAB.
#
# It's purpose is # to examine the current command line (as represented by the 
# array COMP_WORDS) and to determine what the autocomplete should reply through
# the array COMPREPLY.
#
# This function is organized with subroutines who  are responsible for setting 
# the 'candidates' variable.
#
# The compgen then filters out the candidates that don't begin with the word we are
# completing. In this case, if '--' is one of the words, we set empty candidates,
# otherwise, we look at the previous word and delegate # to candidate-setting functions
__complete_gitlab-runner() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
	COMPREPLY=( $(compgen -W "$(__suggest_gitlab_runner_compreply_candidates)" -- ${cur}))
}

__suggest_gitlab_runner_compreply_candidates(){
    if __dash_dash_in_words ; then
        return
    fi

    option=$(__get_current_option)
    if [[ "$option" != "" ]] ; then
        __suggest_gitlab-runner_args_for ${option}
    else
        if [[ $COMP_CWORD == 1 ]] ; then
            __suggest_gitlab-runner_subcommand
            __suggest_gitlab-runner_global_options
        else
            __suggest_gitlab-runner_options
        fi
    fi
}

__suggest_gitlab-runner_subcommand(){
    echo "list run register install uninstall start stop restart status run-single unregister verify artifacts-downloader artifacts-uploader cache-archiver cache-extractor help"
}

__suggest_gitlab-runner_options(){
    echo "--registration-token -r --token -t --url -u --non-interactive --url --registration-token --description --executor --builds-dir --cache-dir"
    __suggest_gitlab-runner_global_options
}

__suggest_gitlab-runner_global_options(){
   echo "--debug
   --log-level -l
   --cpuprofile
   --help -h
   --version -v"
}

__suggest_gitlab-runner_args_for(){
    case "$1" in
        --token|-t)   __suggest_gitlab-runner_tokens ;;
        --url|-u)     __suggest_gitlab-runner_url ;;
        --executor)   __suggest_gitlab-runner_executor ;;
        --builds-dir) __suggest_gitlab-runner_builds-dir ;;
        --cache-dir)  __suggest_gitlab-runner_cache-dir ;;
    esac
}

__suggest_gitlab-runner_tokens(){
    python3 -c "
try:
    import toml
except ImportError:
    import sys
    print('\nPackage toml must be installed for python3 for token completion', file=sys.stderr)
    sys.exit(1)
import os
with open(f'{os.environ[\"HOME\"]}/.gitlab-runner/config.toml', 'r') as f:
    for runner in toml.loads(f.read())['runners']:
        print(runner['token'])
"
}

__suggest_gitlab-runner_url(){
    echo "https://gitlab.science.gc.ca/ci"
}

__suggest_gitlab-runner_executor(){
    echo "shell docker ssh jobrun ordsoumet"
}

__suggest_gitlab-runner_builds-dir(){
    echo $ECCI_BUILDS_DIR
}

__suggest_gitlab-runner_cache-dir(){
    echo $ECCI_CACHE_DIR
}

__dash_dash_in_words(){
    for ((i=0;i<COMP_CWORD-1;i++)) ; do
        w=${COMP_WORD[$i]}
        if [[ "$w" == "--" ]] ; then
            return 0
        fi
    done
    return 1
}

__get_current_option(){
	local prev="${COMP_WORDS[COMP_CWORD-1]}"
    if [[ "$prev" == -* ]] ; then
        echo "$prev"
    fi
}


################################################################################
# Arrange for the __complete_gitlab-runner to be called when completing the
# the following commands
################################################################################
complete -o default -F __complete_gitlab-runner \
    gitlab-runner \
    gitlab-runner-science \
    gitlab-ci-multi-runner \
    gitlab-runner-linux-amd64 \
    gitlab-runner-com
