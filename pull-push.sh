#!/bin/bash

pushd $(dirname $0)
pwd
git checkout git/gitk
git pull
git push
popd
