#!/bin/bash

set -euEo pipefail
shopt -s inherit_errexit

this_dir=$(cd $(dirname $0) && pwd)
this_dir_rel=${this_dir#${HOME}/}

ln -svf ${this_dir_rel}/dot-inputrc ~/.inputrc

