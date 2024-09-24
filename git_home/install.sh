#!/bin/bash

set -euEo pipefail
shopt -s inherit_errexit

this_dir=$(cd $(dirname $0) && pwd)
this_dir_rel=${this_dir#${HOME}/}

case $USER in
    phc001|carphinp)
        ln -sfv ${this_dir_rel}/dot-gitconfig.specific.work ~/.gitconfig.specific ;;
    pcarphin)
        ln -sfv ${this_dir_rel}/dot-gitconfig.specific.home ~/.gitconfig.specific ;;
    *) echo "WARNING: Don't know which gitconfig.specific to link" ;;
esac

ln -sfv ${this_dir_rel}/dot-gitconfig ~/.gitconfig

mkdir -p ~/.config/git
ln -sfv ../../${this_dir_rel}/dot-config/git/ignore ~/.config/git/ignore

