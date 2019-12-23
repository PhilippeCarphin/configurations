#!/bin/zsh

set -u
readlink_f(){
    python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' $0
}

this_file=$(readlink_f $0) 

if [ $? != 0 ]; then
    echo "ERROR: Could not determine realpath for $0"
    exit 1
fi

this_dir=$(dirname ${this_file})
echo "${this_file}"
echo "this_dir = $(dirname ${this_file})"

install_philconfig_group(){
    local group=$1
    if [ -z "${group}" ] ; then
        echo "$0 ERROR : function install_philconfig_group requires one argument"
        return 1
    fi

    # Make the $HOME look like ${this_dir}/${1}_home
    stow -v -t $HOME -d ${this_dir} -S ${1}_home
}

install_philconfig_group zsh
install_philconfig_group vim
install_philconfig_group fish
install_philconfig_group git

