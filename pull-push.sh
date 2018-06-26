#!/bin/bash

echo "# $0 called at $(date)" >> ~/.philconfig/local_file

pushd $(dirname $0)
pwd
git checkout git/gitk
git pull
git push
popd
