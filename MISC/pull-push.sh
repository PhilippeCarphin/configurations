#!/bin/bash

echo "# $0 called at $(date)" >> ~/.philconfig/local_file

pushd $(dirname $0)
pwd
git checkout git/gitk
git push origin master
if at_cmc ; then git push origin cmc ; fi
popd
