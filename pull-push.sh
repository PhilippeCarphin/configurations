#!/bin/bash

echo "$0 called at $(date)"

pushd $(dirname $0)
pwd
git checkout git/gitk
git pull
git push
popd
