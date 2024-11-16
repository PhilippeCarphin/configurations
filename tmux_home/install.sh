#!/bin/bash

set -euEo pipefail
shopt -s inherit_errexit

this_dir=$(cd $(dirname $0) && pwd)
this_dir_rel=${this_dir#${HOME}/}

host=$(hostname -f)
if [[ ${USER} == pcarphin ]] ; then
    ln -sfv ${this_dir_rel}/dot-tmux.conf.colors.home ~/.tmux.conf.colors
    ln -sfv ${this_dir_rel}/dot-tmux.conf.home ~/.tmux.conf.specific
else
    ln -sfv ${this_dir_rel}/dot-tmux.conf.work ~/.tmux.conf.specific
    case ${host} in
        *collab.science.gc.ca)
            ln -svf ${this_dir_rel}/dot-tmux.conf.work.colors collab ~/.tmux.conf.colors ;;
        *science.gc.ca)
            ln -svf ${this_dir_rel}/dot-tmux.conf.work.colors sci ~/.tmux.conf.colors ;;
        *ec.gc.ca)
            ln -svf ${this_dir_rel}/dot-tmux.conf.work.colors ec ~/.tmux.conf.colors ;;
        *)
            echo "$0: Unknown domain" ;;
    esac
fi

