#!/bin/bash
PHILRC_BASHRC=".bashrc sourced at $(date)"

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
sub_function(){
	echo '\[$(tput setaf 9)\]'
}

################################################################################
# Different way of making PS1.  We rewrite PS1 right before it is to be
# displayed.  This is way more simple since we don't have to deal with all the
# weird ways that escaping characters can make our life difficult.
################################################################################
make_ps1(){
    prompt_start="\[$prompt_color\][$(git_pwd)\[$reset_colors\]"
	# git_part='$(__git_ps1 " \[$branch_color\](%s)")$(git_ps1_phil >&2)\[$reset_colors\]'
    git_part="$(git_ps1_phil)"
    if ! [ -z "$git_part" ] ; then
        git_part=" $git_part\[$reset_colors\]"
    fi
	last_part="\[$prompt_color\]] \$\[$reset_colors\] "

	PS1="$prompt_start$git_part$last_part"
}
export PROMPT_COMMAND=make_ps1

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
	source ~/.git-prompt-phil.sh

	export LANG=en_US.UTF-8

	# Set editor as vim for most things
	export EDITOR=vim
	export FCEDIT=vim

	# Make bash behave a bit like vim.
	set -o vi

	# Define colors for making prompt string.
	orange=$(tput setaf 208)
	green=$(tput setaf 2)
	yellow=$(tput setaf 3)
	purple=$(tput setaf 5)
	blue=$(tput setaf 4)
	red=$(tput setaf 9)
	reset_colors=$(tput sgr 0)

	# define variables for prompt colors
	prompt_color=$orange
	branch_color=$yellow

	GIT_PS1_PHIL_HEADLESS_COLOR=$red
	GIT_PS1_PHIL_DIRTY_COLOR=$yellow
	GIT_PS1_PHIL_CLEAN_COLOR=$green

	PS2='\[$purple\] > \[$reset_colors\]'

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
