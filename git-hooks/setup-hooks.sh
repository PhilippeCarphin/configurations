#!/bin/bash

repo_dir=$(git rev-parse --show-toplevel)

link=$repo_dir/.git/hooks/post-commit
link_target=$repo_dir/git-hooks/post-commit

rm -f $link

ln -s $link_target $link
