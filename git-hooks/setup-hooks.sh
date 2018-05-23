#!/bin/bash

repo_dir=$(git rev-parse --show-toplevel)

link_name=$repo_dir/.git/hooks/post-commit
link_target=$repo_dir/git-hooks/post-commit

rm -f $link_name

ln -s $link_target $link_name
