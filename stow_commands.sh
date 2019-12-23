#!/bin/zsh
set -u
set -o errexit
echoerr(){
    echo $@ >&2
}

main(){
    if [ -v 1 ] ; then
        install_philconfig_group $1
    else
        echoerr "Groups to install" >&2
        ls | grep _home | sed 's/^/- /' | sed 's/_home//' >&2
    fi
}
readlink_f(){
    python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' $1
}

this_file=$(readlink_f $0) 

if [ $? != 0 ]; then
    echo "ERROR: Could not determine realpath for $0" >&2
    exit 1
fi

this_dir=$(dirname ${this_file})

install_philconfig_group(){
    if ! [ -v 1 ] ; then
        echo "$0 ERROR : function install_philconfig_group requires one argument" >&2
        return 1
    fi
    local group=$1

    if ! [ -d ${this_dir}/${1}_home ] ; then
        echoerr "$0 ERROR : no such group ${1} (${1}_home)"
        return 1
    fi

    # Make the $HOME look like ${this_dir}/${1}_home
    stow -v -t $HOME -d ${this_dir} -S ${1}_home
}

main $@
