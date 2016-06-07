echo Caller is $0

if [ "$CMCLNG" != "" ]; then
   export SEQ_TRACE_LEVEL=1:TL_FULL_TRACE
   if [ `which git` = /usr/bin/git ] ; then
      # To protect against using a bad version of git.
      alias git="echo bad version of git"
   fi
   case $- in
      *i*)
         export domain="/users/dor/afsi/phc/Testing/testdomain"
         export CMCLNG=english
         echo "   Loading CMC commands "
         . ssmuse-sh -d cmoi/apps/git/20150526
         . ssmuse-sh -d cmoi/apps/git-procedures/20150622
         if [ `hostname` == artanis ] ; then
            echo "      ssm'ing maestro 1.5 test version"
            maestro=$domain
         else
            echo "      ssm'ing maestro 1.5.0-rc7"
            maestro=/ssm/net/isst/maestro/1.5.0-rc7
         fi
         . ssmuse-sh -d $maestro
         export SEQ_MAESTRO_SHORTCUT=". ssmuse-sh -d $maestro"
         alias runxp=/users/dor/afsi/dor/ovbin/i686/runxp
         alias xflow_overviewSuites="xflow_overview -suites ~afsiops/xflow.suites.xml;echo allo"
         alias runxp_phil='/usr/bin/rdesktop -a 16 -r sound:local -g 1500x1100 eccmcwts3'
         alias cmc_origin='cd /home/ordenv/GIT-DEPOTS/impl/isst'
         alias dor_origin='cd /home/ops/afsi/dor/tmp/maestro_depot'
         alias emake='make 2>&1 | grep '.*error' --color=always --after-context=4'
         alias wmake='make 2>&1 | grep '.*warning' --color=always --after-context=4'
         alias nmake='make 2>&1 | grep '.*note' --color=always --after-context=4'


         if [ `hostname` != artanis ] ; then
            alias mcompile='export SEQ_EXP_HOME=$HOME/Documents/Experiences/compilation && maestro -d 20160119000000 -n /compile -s submit -f continue'
            alias xcompile='export SEQ_EXP_HOME=$HOME/Documents/Experiences/compilation && xflow'
         fi

         . ssmuse-sh -d $maestro
         export SEQ_MAESTRO_SHORTCUT=". ssmuse-sh -d $maestro"
         ;;
      *)
         ;;
   esac
fi


case $- in
   *i*)

   . ~/.git-prompt.sh
   alias profile="vim $HOME/.bashrc"
   alias lprofile=". $HOME/.bashrc"
   alias cd..='cd ..'
   alias dusage='du --max-depth=1 | sort -n'
   alias gitk="gitk --all --select-commit=HEAD"
   alias vgrindtotmem="valgrind --tool=massif --stacks=yes"
   alias vgrind="valgrind --tool=memcheck --leak-check=yes"
   alias grep='grep --color=always -n'
   alias less='less -R'
   export CDPATH=$CDPATH:$HOME/Documents/GitCMC/:$HOME/Documents/Experiences/:$HOME:$HOME/Documents
   export PATH=$HOME/.local/cmake-3.5.0-rc1-Linux-x86_64/bin:$HOME/.local/bin:$HOME/Documents/test:$PATH
   export EDITOR=vim
   export FCEDIT=vim


   ssh_school() {
      ssh $1.info.polymtl.ca -l phcarb
   }

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
   cdl () {
       cd "$(dirname "$(readlink "$1")")";
   }
   set -o vi

   if [ "$BASH" != "" ]; then
      echo "   Loading bash specific commands"
      green='\[\e[0;32m\]'
      yellow='\[\e[0;33m\]'
      purple='\[\e[0;35m\]'
      no_color='\[\e[0m\]'
      PS1=$green'[\u@\h \W'$yellow'$(__git_ps1 " (%s)")'$green'] \$ '$no_color
      [ -z "$TMUX" ] && export TERM=xterm-256color
      . ~/.git-completion.bash
      export HISTFILESIZE=
      export HISTSIZE=
   else
      green='\033[32m'
      yellow='\033[33m'
      purple='\033[35m'
      no_color='\033[00m'
      echo "   Loading non-bash commands (possibly ksh)"
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
   ;;
esac
