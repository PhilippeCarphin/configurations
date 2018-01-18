#!/bin/bash
export PHILRC_BASHRC=".bashrc sourced at $(date)"

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

BASHRC_LOADED=true

################################################################################
# Echoes a shortened version of host name when at polytechnique
################################################################################
short_host(){
	H=$(uname -n)
	if [[ $H == *EDUROAM* ]]; then
		echo "Sansfil-Poly"
	elif [[ $H == *.polymtl.ca ]] ; then
		echo "Sansfil-Poly"
	else
		echo "$H"
	fi
}


################################################################################
# Checks for interactive shell.  The following will only be done if the shell is
# an interactive session.  Otherwise these things should not be done.
################################################################################
if [[ "$-" == *i* ]] ; then

	source ~/.general-aliases
	source ~/.functions
	source ~/Templates/.template-completion.bash

	source ~/.git-completion.bash
	source ~/.git-prompt.sh

	export LANG=en_US.UTF-8

	# cd into some directories from anywhere.
	export CDPATH=$CDPATH:$HOME/Documents/GitCMC/:$HOME/Documents/Experiences/:$HOME:$HOME/Documents

	# Set editor as vim for most things
	export EDITOR=vim
	export FCEDIT=vim

	# Make bash behave a bit like vim.
	set -o vi

	# Define colors for making prompt string.
	green='\[$(tput setaf 2)\]'
	yellow='\[$(tput setaf 3)\]'
	purple='\[$(tput setaf 5)\]'
	blue='\[$(tput setaf 4)\]'
	no_color='\[$(tput sgr 0)\]'
	PS1=$green'[\W'$yellow'$(__git_ps1 " (%s)")'" $green"'] \$ '$no_color
	PS2=$purple' > '$no_color

	#if in tmux, export this I forget why
	if [ -z "$TMUX" ] ; then
		export TERM=xterm-256color
	fi

	# Make history infinite.
	export HISTFILESIZE=
	export HISTSIZE=

	# Checking that my username is my polytechnique username
	if [ "$USER" = phcarb -o "$USER" = "" ]; then
		true
	fi
fi
