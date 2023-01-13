#!/bin/bash


__complete_ssm() {
    # log "__complete_ssm() BEGIN"
    local cur="${COMP_WORDS[COMP_CWORD]}"
	COMPREPLY=( $(compgen -W "$(__suggest_ssm_compreply_candidates)" -- ${cur}))
    # log "__complete_ssm() END"
}

__suggest_ssm_compreply_candidates(){
    if __dash_dash_in_words ; then
        return
    fi
    # log "dash dash is not in words"

    subcommand=$(__get_ssm_subcommand)
    if [[ "${subcommand}" != "" ]] ; then
        # log "Subcommand is '${subcommand}'"
        option=$(__get_current_option)
        if [[ "$option" != "" ]] ; then
            __suggest_ssm_values_for_option ${option}
        else
            __suggest_ssm_options_for_subcommand ${subcommand}
        fi
    else
        __suggest_ssm_subcommand
    fi
}

__suggest_ssm_install_compreply_candidates(){
    true
}

__suggest_ssm_options_for_subcommand(){
    case "$1" in
        diffd)     __suggest_ssm_diffd_options ; return ;;
        invd)      __suggest_ssm_invd_options ; return ;;
        listd)     __suggest_ssm_listd_options ; return ;;

        install)   __suggest_ssm_install_options ; return ;;
        uninstall) __suggest_ssm_uninstall_options ; return ;;
        publish)   __suggest_ssm_publish_options ; return ;;
        unpublish) __suggest_ssm_unpublish_options ; return ;;

        cloned)    __suggest_ssm_cloned_options ; return ;;
        created)   __suggest_ssm_created_options ; return ;;
        upgraded)  __suggest_ssm_upgraded_options ; return ;;
    esac
}

__suggest_ssm_diffd_options(){
    echo "--meta --installed --published --debug --force --verbose"
}

__suggest_ssm_invd_options(){
    echo "-d --debug --verbose"
}

__suggest_ssm_listd_options(){
    echo "-d -p -pp --debug --force --verbose"
}

__suggest_ssm_install_options(){
    echo "-d -f -p -x -s --names -r --reinstall --skeleton --debug --force --verbose"
}

__suggest_ssm_uninstall_options(){
    echo "-d -p -x --debug --force --verbose"
}

__suggest_ssm_publish_options(){
    echo "-d -p -x -pp --debug --force --verbose"
}

__suggest_ssm_unpublish_options(){
    echo "-d -p -x -pp --debug --force --verbose"
}
__suggest_ssm_cloned_options(){
    echo "--installed --publish --published-src -L -pp -r --debug --force --verbose"
}
__suggest_ssm_created_options(){
    echo "-d -L -r --debug --force --verbose"
}
__suggest_ssm_upgraded_options(){
    echo "--meta --installed --published --debug --force --verbose"
}
__get_ssm_subcommand(){
    for w in "${COMP_WORDS[@]}" ; do
        case $w in
            diffd)     echo $w ; return ;;
            invd)      echo $w ; return ;;
            listd)     echo $w ; return ;;

            install)   echo $w ; return ;;
            uninstall) echo $w ; return ;;
            publish)   echo $w ; return ;;
            unpublish) echo $w ; return ;;

            cloned)    echo $w ; return ;;
            created)   echo $w ; return ;;
            upgraded)  echo $w ; return ;;
        esac
    done
}

__suggest_ssm_subcommand(){
    echo "diffd invd listd install uninstall publish unpublish cloned created upgraded"
}

__suggest_ssm_options(){
    echo "--registration-token -r --token -t --url -u --non-interactive --url --registration-token --description --executor --builds-dir --cache-dir"
    __suggest_ssm_global_options
}

__suggest_ssm_global_options(){
   echo "--debug
   --log-level -l
   --cpuprofile
   --help -h
   --version -v"
}

__suggest_ssm_args_for(){
    case "$1" in
        --token|-t)   __suggest_ssm_tokens ;;
        --url|-u)     __suggest_ssm_url ;;
        --executor)   __suggest_ssm_executor ;;
        --builds-dir) __suggest_ssm_builds-dir ;;
        --cache-dir)  __suggest_ssm_cache-dir ;;
    esac
}

__suggest_ssm_tokens(){
    # If sourcin through a link, this function will still find the python3 that gets the tokens.
    # However, it will only resolve one level of symbolic link
    # And using readlink -f would make it unportable to BSD based OS's
    python3 $(dirname "$(readlink "${BASH_SOURCE[0]}")")/get_tokens.py
}

__suggest_ssm_url(){
    echo "https://gitlab.science.gc.ca/ci"
}

__suggest_ssm_executor(){
    echo "shell docker ssh jobrun ordsoumet"
}

__suggest_ssm_builds-dir(){
    echo $ECCI_BUILDS_DIR
}

__suggest_ssm_cache-dir(){
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
complete -o default -F __complete_ssm ssm
