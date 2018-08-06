#!/bin/bash
replace_with_link(){
   original=$1
   target=$installDir/$2
   if [ -L $original ] ; then
      rm $original
   else
      mv $original $original.bak
   fi
   ln -s $target $original
}

replace_with_link $HOME/.bashrc bashrc
replace_with_link $HOME/.bash_profile bash_profile
replace_with_link $HOME/.vimrc vimrc
replace_with_link $HOME/.gitconfig gitconfig
replace_with_link $HOME/.git-completion.bash git-completion.bash
replace_with_link $HOME/.git-prompt.sh git-prompt.sh
replace_with_link $HOME/.tmux.conf tmux.conf
