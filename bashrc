echo Caller is $0
# ALL

   . ~/.git-prompt.sh
   alias profile="vim $HOME/.bashrc"
   alias lprofile=". $HOME/.bashrc"
   alias cd..='cd ..'
   alias dusage='du --max-depth=1 | sort -n'
   alias gitk="gitk --all"
   alias vgrindtotmem="valgrind --tool=massif --stacks=yes"
   alias vgrind="valgrind --tool=memcheck --leak-check=yes"
   export CDPATH=$CDPATH:$HOME/Documents/GitCMC/:$HOME/Documents/Experiences/:$HOME:$HOME/Documents
   export PATH=$HOME/.local/cmake-3.5.0-rc1-Linux-x86_64/bin:$HOME/.local/bin/:$HOME/Documents/test/:$PATH
   export EDITOR=vim
   export FCEDIT=vim


   ssh-school() {
      ssh $1.info.polymtl.ca -l phcarb
   }
   cdl () {
       cd "$(dirname "$(readlink "$1")")";
   }
   set -o vi

if [ "$CMCLNG" != "" ]; then
   echo "   Loading CMC commands "
   . ssmuse-sh -d cmoi/apps/git/20150526
   . ssmuse-sh -d cmoi/apps/git-procedures/20150622
   alias runxp=/users/dor/afsi/dor/ovbin/i686/runxp 
   alias xflow_overviewSuites="xflow_overview -suites ~afsiops/xflow.suites.xml;echo allo"
   alias runxp_phil='/usr/bin/rdesktop -a 16 -r sound:local -g 1500x1100 eccmcwts3'
   alias ssmtest='. ssmuse-sh -d /users/dor/afsi/phc/Testing/testdomain'
   alias exportssmtest='export SEQ_MAESTRO_SHORTCUT=". ssmuse-sh -d /users/dor/afsi/phc/Testing/testdomain"'
   alias cmc_origin='cd /home/ordenv/GIT-DEPOTS/impl/isst'
   alias dor_origin='cd /home/ops/afsi/dor/tmp/maestro_depot'
   export CMCLNG=english
   export SEQ_TRACE_LEVEL=1:TL_FULL_TRACE
   export domain="/users/dor/afsi/phc/Testing/testdomain"
   if [ `hostname` == artanis ] ; then
      echo "      ssm'ing maestro 1.5 test version"
      . ssmuse-sh -d /users/dor/afsi/phc/Testing/testdomain
      export SEQ_MAESTRO_SHORTCUT=". ssmuse-sh -d /users/dor/afsi/phc/Testing/testdomain"
   else
      echo "      ssm'ing maestro 1.4.3-rc4"
      . ssmuse-sh -d /ssm/net/isst/maestro/1.4.3-rc4
      export SEQ_MAESTRO_SHORTCUT=". ssmuse-sh -d /ssm/net/isst/maestro/1.4.3-rc4"
      alias mcompile='export SEQ_EXP_HOME=$HOME/Documents/Experiences/compilation && maestro -d 20160119000000 -n /compile -s submit -f continue'
      alias xcompile='export SEQ_EXP_HOME=$HOME/Documents/Experiences/compilation && xflow'
   fi
fi

if [ "$BASH" != "" ]; then 
   echo "   Loading bash specific commands"
   PS1='\[\e[0;32m\][\u@\h \W\[\e[0;33m\]$(__git_ps1 " (%s)")\[\e[0;32m\]] \$ \[\e[0m\]'
   [ -z "$TMUX" ] && export TERM=xterm-256color
   . ~/.git-completion.bash 
   export HISTFILESIZE=
   export HISTSIZE=
else
   echo "   Loading non-bash commands (possibly ksh)"
   ulimit -St unlimited
   if [ `hostname` = artanis ] ; then 
      echo "    git prompt doesn't work on ubuntu14's ksh :("
      PS1='$(echo -e "\033[32m${LOGNAME} @ ${HOSTNAME} ${PWD##*/} $ \033[00m")'
   else
      PS1='$(echo -e "\033[32m${LOGNAME} @ ${HOSTNAME} ${PWD##*/}\033[35m$(__git_ps1 " (%s)")\033[32m $ \033[00m")'
   fi
	alias history='fc -l 1 100000'
	alias __A=$(print '\0020') # ^P = up = previous command
	alias __B=$(print '\0016') # ^N = down  = next command
	alias __C=$(print '\0006') # ^F = right = forward a character
	alias __D=$(print '\0002') # ^B = left = back a character
	alias __H=$(print '\0001') # ^A = home = beginning of line
	alias __Y=$(print '\0005') # ^E = end = end of line
fi

if [ "$USER" = prcarb ]; then # We're at polytechnique
   echo "   Loading polytechnique commands"
   alias INF1995='firefox http://www.groupes.polymtl.ca/inf1995/tp/'
   alias docAtmel='gvfs-open ~/Documents/docAtmel.pdf'
   # Put the PDF of the Atmel documentation in the documents folder.

   alias docAVRLibC='firefox http://www.nongnu.org/avr-libc/user-manual/index.html'
   alias chrome='google-chrome'
   alias INF1995='google-chrome http://www.groupes.polymtl.ca/inf1995/tp/'
   alias hotmail='google-chrome www.hotmail.com'
fi

if [ `uname` = Linux ]; then
   echo "   Loading Linux commands"
	alias ls='ls --color'
elif [ `uname` = Darwin ]; then
   echo "   Loading Darwin commands"   
	alias ls='ls -G'
   alias dusage='du -d 1 | sort -n'
elif [ $(uname) = AIX ]; then
   echo "   Loading AIX commands"   
   if [ "$BASH" = "" ]; then
      PS1="${LOGNAME} @ ${HOSTNAME} "'!) '
   fi
	alias vim=vi
	alias gvim=vi
fi

if [ "$TMUX" = "" -a "$SSH_CLIENT" = "" ] ; then
   tmux
fi
