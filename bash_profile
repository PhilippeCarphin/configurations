#!/bin/bash

export PHILRC_BASH_PROFILE="bash_profile loaded at $(date)"

if ! env | grep PHILRC_BASHRC ; then
	# At Poly and on my Fedora computer, bashrc doesn't get sourced unless I
	# source it myself from another script
	source ~/.bashrc
fi


source ~/.envvars
