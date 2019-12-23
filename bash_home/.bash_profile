#!/bin/bash
# echo ".bash_profile START"
export PHILCONFIG=$(cd -P $(dirname $(readlink ${BASH_SOURCE[0]})) > /dev/null && pwd)

source $PHILCONFIG/FILES/initutils




if [ -z $PHILRC_BASH_PROFILE ] ; then
    # Acutal bash_profile
    if [ $(hostname) = kano ] ; then
        sshfs phc001@ppp1:/fs/site1/dev/eccc/cmd/s/phc001/boost_python_tests/build ~/ppp1/boost_python_tests/build
        sshfs phc001@ppp1:/fs/home/fs1/eccc/cmd/cmds/phc001/workspace/boost_python_tests ~/ppp1/boost_python_tests/source

        sshfs phc001@ppp1:/fs/site1/dev/eccc/cmd/s/phc001/spooki/build ~/ppp1/spooki/build
        sshfs phc001@ppp1:/fs/home/fs1/eccc/cmd/cmds/phc001/workspace/spooki ~/ppp1/spooki/source

        mkdir -p ~/ppp2/spooki/build
        mkdir -p ~/ppp2/spooki/source
        sshfs phc001@ppp2:/fs/site1/dev/eccc/cmd/s/phc001/spooki/build ~/ppp2/spooki/build
        sshfs phc001@ppp2:/fs/home/fs1/eccc/cmd/cmds/phc001/workspace/spooki ~/ppp2/spooki/source
    fi

    # If ssh login shell that I would like to be interactive
    # if ! [ -z "$SSH_CLIENT" ] && ! [ -z "$SSH_TTY" ] && [ -z $PHILRC_BASHRC ]; then
    # TEMPORARY SOLUTION: ALWAYS SOURCE BASHRC, (anyway it contains a check that the shell is interactive)
    if true ; then
       source ~/.bashrc
    fi
else
    # if bash_profile has already been sourced, then this file is most likely
    # being sourced becasue TMUX has started a login shell.  In that case, we
    # want to source our bashrc
    source ~/.bashrc
    return
fi

export PHILRC_BASH_PROFILE="bash_profile_loaded_at_$(date "+%Y-%m-%d_%H%M")"
# echo ".bash_profile END"
