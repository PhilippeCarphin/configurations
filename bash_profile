#!/bin/bash

export PHILRC_BASH_PROFILE="bash_profile loaded at $(date)"

if [[ "$USER" == phcarb ]] ; then
	source ~/.bashrc
fi

source ~/.envvars
