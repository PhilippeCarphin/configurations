#!/bin/bash

my_dir=$(cd $(dirname $0) > /dev/null; pwd)

cd $my_dir
repo_dir=$(git rev-parse --show-toplevel)

link_name=$repo_dir/.git/hooks/post-commit
link_target=$repo_dir/MISC/git-hooks/post-commit

rm -f $link_name
ln -s $link_target $link_name
