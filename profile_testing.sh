#!/bin/bash

function make_like_work(){
    (
        cd
        for f in .bashrc .bash_profile ; do
            if [[ -L $f ]] ; then
                rm -v $f
            elif [[ -f $f ]] ; then
                echo "warning: $f is not a link"
            fi
        done
        for f in .philconfig/cmc_home/dot-profile ; do
            ln -vsf $f .${f##*dot-}
        done
    )
}

function make_like_home(){
    (
        cd
        for f in .profile ; do
            if [[ -L $f ]] ; then
                rm -v $f
            elif [[ -f $f ]] ; then
                echo "warning: $f is not a link"
            fi
        done
        for f in .philconfig/bash_home/dot-{bashrc,bash_profile}; do
            ln -vfs $f .${f##*dot-}
        done
    )
}
