#!/usr/bin/env bash

set -euEo pipefail
shopt -s inherit_errexit

this_dir=$(cd $(dirname $0) && pwd)
this_dir_rel=${this_dir#${HOME}/}

ln -sfv ${this_dir_rel}/dot-tmux.conf ~/.tmux.conf

if [[ ${USER} == pcarphin ]] ; then
    ln -sfv ${this_dir_rel}/dot-tmux.conf.colors.home ~/.tmux.conf.colors
    ln -sfv ${this_dir_rel}/dot-tmux.conf.home ~/.tmux.conf.specific
else
    ln -sfv ${this_dir_rel}/dot-tmux.conf.work ~/.tmux.conf.specific
    host=$(hostname -f)
    case ${host} in
        *collab.science.gc.ca)
            ln -svf ${this_dir_rel}/dot-tmux.conf.colors.work.collab ~/.tmux.conf.colors ;;
        ppp7*)
            ln -svf ${this_dir_rel}/dot-tmux.conf.colors.work.sci.u3 ~/.tmux.conf.colors ;;
        *science.gc.ca)
            ln -svf ${this_dir_rel}/dot-tmux.conf.colors.work.sci ~/.tmux.conf.colors ;;
        *ec.gc.ca)
            ln -svf ${this_dir_rel}/dot-tmux.conf.colors.work.ec ~/.tmux.conf.colors ;;
        *)
            echo "$0: Unknown domain: '$host'" ;;
    esac
fi

