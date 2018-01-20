#!/bin/bash

git_dir=$(git rev-parse --show-toplevel)

rm -f $git_dir/.git/hooks/post-commit
ln -s $git_dir/.git-hooks/post-commit $git_dir/.git/hooks/post-commit
