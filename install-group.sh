#!/bin/bash
#set -u
set -o errexit
set -o nounset
set -o pipefail
set -o errtrace
echoerr(){
    echo $@ >&2
}

main(){
    ensure-stow
    if [ -z "${1-}" ] ; then
        echoerr "ERROR: Need 1 argument: Group to install. Possible values :" >&2
        ls | grep _home | sed 's/^/- /' | sed 's/_home//' >&2
        return 1
    fi

    install_philconfig_group $1
}
readlink_f(){
    python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' $1
}

this_file=$0

if [ $? != 0 ]; then
    echo "ERROR: Could not determine realpath for $0" >&2
    exit 1
fi

this_dir=$(dirname ${this_file})
printf "this_dir = \033[1;32m%s\033[0m\n" ${this_dir}

install_philconfig_group(){
    if [ -z "${1-}" ] ; then
        echo "$0 ERROR : function install_philconfig_group requires one argument" >&2
        return 1
    fi
    local group=$1

    if ! [ -d ${this_dir}/${1}_home ] ; then
        echoerr "$0 ERROR : no such group ${1} (${1}_home)"
        return 1
    fi

    # Make the $HOME look like ${this_dir}/${1}_home
    cmd="stow -v -t $HOME -d ${this_dir} -R ${1}_home --dotfiles"
    printf "Stow command : \033[32m%s\033[0m\n" "${cmd}"
    $cmd
}

function ensure-stow(){
    if ! which stow ; then
        printf "Please install GNU stow and make it available in your path"
        exit 1
    fi
}

main $@
