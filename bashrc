#!/bin/bash
if [[ "$BASHRC_LOADED" == true ]] ; then
	echo "bashrc Already loaded"
fi
BASHRC_LOADED=true

################################################################################
# Echoes a shortened version of host name when at polytechnique
################################################################################
host(){
	H=$(uname -n)
	if [[ $H == Sansfil-Securise-Etudiants* ]]; then
		echo "Sansfil-Poly"
	else
		echo "$H"
	fi
}
################################################################################
# Adds one file and commits it with message
################################################################################
commit1(){
	git add $1 && git commit -m "$2"
}

################################################################################
# Uses find to go to a directory that is not in the PWD nor on CDPATH
# If the target is a directory, we go into it, if the target is a file, we go
# into the directory containing the file.
################################################################################
cdf(){
	result="$(find . -name "$1" -print -quit)"
	if [[ -d "$result" ]] ; then
		cd $result
		echo $(pwd)
	elif [[ -f "$result" ]] ; then
		cd "$(dirname "$result")"
		echo $(pwd)
	elif [[ $result == "" ]]; then
		echo "cdf: nothing found matching $1"
	else
		echo "result $result could not be cd'd into"
	fi
}

################################################################################
# Git push all branches to repository
################################################################################
pushall(){
	# Todo: upgrade this to prompt for each branch (asking y/n) whether we want
	# to push it.
	if [[ $1 == "" ]]; then
		remote=origin
	else
		remote=$1
	fi
	for b in $(git branch | tr '*' ' ' |tr '\n' ' '); do
		echo -n "Push branch $b (y/n)? "
		read answer
		if [[ "$answer" == y ]] ; then
			git push $remote $b;
		fi
	done
}


################################################################################
# Connects over ssh to school computer of my choice
################################################################################
ssh_school() {
	if [[ $1 == "" ]]; then
		computer="l3818-01"
	else
		computer=$1
	fi
	ssh $computer.info.polymtl.ca -l phcarb
}

################################################################################
# Uses find to go to a directory that is not in the PWD nor on CDPATH
################################################################################
p_valgrind(){
	flags=$3
	cmd=$1
	if [ "$2" != "" ] ; then
		target=$2
	else
		target=~/valgrind.lst
	fi
	valgrind $flags $cmd > $target 2>&1
}


################################################################################
# Follows one level of link indirection.  The target must be a link otherwise
# readlink returns nothing.
################################################################################
cdl () {
	cd "$(dirname "$(readlink "$1")")";
}

################################################################################
# Checks for interactive shell.  The following will only be done if the shell is
# an interactive session.  Otherwise these things should not be done.
################################################################################
case $- in
	*i*)
		# Echo who is sourcing this script.
		echo Caller is $0

		# Loading soursing this script allows the __git_ps1 function to be
		# called to that I can see my branch in my prompt string.
		. ~/.git-prompt.sh

		# Make sure git's language is english
		# Ref : http://askubuntu.com/questions/320661/change-gits-language-to-english-without-changing-the-locale
		# the site says to make an alias
		# alias git='LANG=en_US.UTF-8 git'
		# but I want everything to be in english so I'm going to do this:
		export LANG=en_US.UTF-8

		# Allows me to open my bashrc quickly and reload it quickly
		alias profile="vim $HOME/.bashrc && . $HOME/.bashrc"
		alias lprofile=". $HOME/.bashrc"

		# If I skip the space with cd ..
		alias cd..='cd ..'

		# See disk usage: lists the sizes of the folders in the current
		# directory and sorts them by size
		alias dusage='du --max-depth=1 | sort -n'

		# Make gitk always show all branches
		alias gitk="gitk --all --select-commit=HEAD &"

		# Quick aliases for valgrind
		alias vgrindtotmem="valgrind --tool=massif --stacks=yes"
		alias vgrind="valgrind --tool=memcheck --leak-check=yes"

		# Make grep show colors and line numbers
		alias grep='grep --color=always -n'

		# Make less accept colored input
		alias less='less -R'

		# Add PWD to path for current session.  Useful for recompiling and
		# running executables without always writing './'
		alias pathpwd='export PATH=$PWD:$PATH'

		# Aliases for quick directories:
		alias github='cd ~/Documents/GitHub'

		source ~/.github-aliases
		alias new-repo='source new-repo.sh'

		# Add certain directories to CDPATH environment variable so that we can
		# cd into some directories from anywhere.
		export CDPATH=$CDPATH:$HOME/Documents/GitCMC/:$HOME/Documents/Experiences/:$HOME:$HOME/Documents

		# Set editor as vim for most things
		export EDITOR=vim
		export FCEDIT=vim

		# Opens the master PDF documenation for ATMega324PA assuming it is
		# at this path.
		alias docatmel='gvfs-open ~/Documents/docatmel.pdf'

		# Make bash behave a bit like vim.
		set -o vi

		if [ "$BASH" != "" ]; then
			echo "   Loading bash specific commands"

			# Define colors for making prompt string.
			green='\[$(tput setaf 2)\]'
			yellow='\[$(tput setaf 3)\]'
			purple='\[$(tput setaf 5)\]'
			no_color='\[$(tput sgr 0)\]'
			# Prompt string shows user@host current_dir (git branch) with
			# everything except git branch in green and the branch in yellow
			# PS1=$green'[\u@'$(host)' \W'$yellow'$(__git_ps1 " (%s)")'$green'] \$ '$no_color
			PS1=$green'[\W'$yellow'$(__git_ps1 " (%s)")'$green'] \$ '$no_color
			PS2=$purple' > '$no_color
			# PS1=$green'[\u@$(host) \W'$no_color$yellow'$(__git_ps1 " (%s)")'$no_color$green'] \$ '$no_color

			#if in tmux, export this I forget why
			if [ -z "$TMUX" ] ; then
				export TERM=xterm-256color
			fi

			# Source git completion script.  Works only with bash shell
			. ~/.git-completion.bash
			. ~/Templates/.template-completion.bash

			# Make history infinite.
			export HISTFILESIZE=
			export HISTSIZE=
		else
			echo "   Loading non-bash commands (possibly ksh)"
			# Phil_PS1
			green='\033[32m'
			yellow='\033[33m'
			purple='\033[35m'
			no_color='\033[00m'
			ulimit -St unlimited
			if [ "${KSH_VERSION#*PD}" != "$KSH_VERSION" ] ; then
				echo "    Running pdksh"
				PS1='$(echo -e "$green${LOGNAME} @ ${HOSTNAME} ${PWD##*/}$purple$(__git_ps1 " (%s)")$green \$ $no_color")'
			else
				echo "    git prompt doesn't work on ksh93 :("
				PS1='$(echo -e "$green${LOGNAME} @ ${HOSTNAME} ${PWD##*/} $ $no_color")'
			fi
			alias history='fc -l 1 100000'
			alias __A=$(print '\0020') # ^P = up = previous command
			alias __B=$(print '\0016') # ^N = down  = next command
			alias __C=$(print '\0006') # ^F = right = forward a character
			alias __D=$(print '\0002') # ^B = left = back a character
			alias __H=$(print '\0001') # ^A = home = beginning of line
			alias __Y=$(print '\0005') # ^E = end = end of line
		fi

		if [ "$USER" = phcarb -o "$USER" = "" ]; then # We're at polytechnique
			echo "   Loading polytechnique commands"

			# Opens AvrLibC documentation
			alias docAVRLibC='firefox http://www.nongnu.org/avr-libc/user-manual/index.html'

			# Opens INF1995 page
			alias INF1995='google-chrome http://www.groupes.polymtl.ca/inf1995/tp/'
		fi

		# OS specific commands
		if [ $(uname) = Linux ]; then
			echo "   Loading Linux commands"
			# ls always shows color
			alias ls='ls --color'
		elif [ $(uname) = Darwin ]; then
			echo "   Loading Darwin commands"
			# ls always shows color
			alias ls='ls -G'
			# Redefine dusage command for MAC
			alias dusage='du -d 1 | sort -n'
		fi
		;;
esac
