#!/bin/bash
PHILRC_BASHRC=".bashrc sourced at $(date)"
# echo ".bashrc START"

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

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
# Different way of making PS1.  We rewrite PS1 right before it is to be
# displayed.  This is way more simple since we don't have to deal with all the
# weird ways that escaping characters can make our life difficult.
################################################################################
make_ps1(){
    previous_exit_code=$?
    if [[ $previous_exit_code == 0 ]] ; then
       pec="\[$green\] 0 \[$reset_colors\]"
    else
       pec="\[$(tput setaf 1)\] $previous_exit_code \[$reset_colors\]"
    fi
    prompt_start="\[$prompt_color\][$(git_pwd)\[$reset_colors\]"
    git_part="$(git_ps1_phil)"
    if ! [ -z "$git_part" ] ; then
        git_part=" $git_part\[$reset_colors\]"
    fi
	 last_part="\[$prompt_color\]] \$\[$reset_colors\] "

	 PS1="$pec$prompt_start$git_part$last_part"
}

################################################################################
# 
################################################################################
bashrc_configure_prompt(){
	export PROMPT_COMMAND=make_ps1
	# Define colors for making prompt string.
	orange=$(tput setaf 208)
	green=$(tput setaf 2)
    yellow=$(at_cmc && tput setaf 11 || tput setaf 3)
	purple=$(tput setaf 5)
	blue=$(tput setaf 4)
	red=$(tput setaf 9)
	reset_colors=$(tput sgr 0)

	# define variables for prompt colors
    prompt_color=$purple

	GIT_PS1_PHIL_HEADLESS_COLOR=$red
	GIT_PS1_PHIL_DIRTY_COLOR=$orange
	GIT_PS1_PHIL_CLEAN_COLOR=$green

	PS2='\[$purple\] > \[$reset_colors\]'
}

################################################################################
# 
################################################################################
bashrc_configure_history(){

	# Make history infinite.
	export HISTFILESIZE=
	export HISTSIZE=
}

################################################################################
# 
################################################################################
bashrc_cmc_specifics(){
   # This file must be sourced by bash before zsh is launched
   cmc_check_git
   source ~/.profile
   if ! [ -e ~/.normal_mode ] ; then
      exec zsh
      true # This is needed for when I comment out the first line (bash
           # doens't allow empty if blocks
   else
      check_quota
      unset CDPATH
   fi
   source $CONFIG_DIR/CMC/aliases.sh
   # source ~/.profile.d/jp-aliases.sh
   # source ~/.profile.d/jp-functions.sh
}

################################################################################
# 
################################################################################
bashrc_set_vim_keybindigs(){
	# Make bash behave a bit like vim.
   if ! [ -e ~/.normal_mode ] ; then
      set -o vi
   fi
}

################################################################################
# 
################################################################################
bashrc_poly_specifics(){
	true
}

################################################################################
# Checks for interactive shell.  The following will only be done if the shell is
# an interactive session.  Otherwise these things should not be done.
################################################################################
if [[ "$-" == *i* ]] ; then

	source ~/.functions
	source ~/.general-aliases
	source ~/Templates/.template-completion.bash
	source ~/.git-completion.bash
	source ~/.git-prompt.sh
	source ~/.git-prompt-phil.sh
	source $CONFIG_DIR/CMC/aliases.sh

	bashrc_set_vim_keybindigs
    bashrc_configure_prompt
    bashrc_configure_history

    if    at_cmc ; then bashrc_cmc_specifics
    elif at_poly ; then bashrc_poly_specifics
    fi

fi

BASHRC_LOADED=true
# echo ".bashrc END"
