#!/bin/bash

repo_dir=$(git rev-parse --show-toplevel)

target=$repo_dir/.git/hooks/post_commit
src=$repo_dir/git-hooks/post_commit

rm -f $target

ln -s $src $target
