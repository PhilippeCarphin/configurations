echo Caller is $0
__paul_check(){
   echo "|" >> ~/.paul_check.txt
   checks=$(cat ~/.paul_check.txt | wc | cut -d ' ' -f 8)
   echo Better pay up, you\'re at $checks checks.
}

paul_check(){
if [ `hostname` == MacBook-Pro.local ] ; then
   echo "source ~/.bashrc && __paul_check" | ssh pcarphin@imac
else
   __paul_check
fi
}



if [ "$CMCLNG" != "" ]; then
   . CMC.sh

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
   alias pathpwd='export PATH=$PWD:$PATH'
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
