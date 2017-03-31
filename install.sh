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

installGroup() {
case $1 in
	bash)
      replace_with_link $HOME/.bashrc bashrc
      replace_with_link $HOME/.bash_profile bash_profile
		;;
	vim)
      replace_with_link $HOME/.vimrc vimrc
	  replace_with_link $HOME/.ideavimrc vimrc # Pycharm uses this
      replace_with_link $HOME/.vim/colors vim/colors
      replace_with_link $HOME/.vim/indent vim/indent
      replace_with_link $HOME/.vim/plugin vim/plugin
	  replace_with_link $HOME/.ycm_extra_conf.py ycm_extra_conf.py
      if [ ! -e $HOME/.vim/bundle/Vundle.vim ] ; then
         git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
      fi
      vim +:PluginInstall # for the plugins managed by vundle to be installed.
		;;
	Templates)
      replace_with_link $HOME/Templates Templates
      if [ `uname` = Linux ] ; then
         killall nautilus # For templates to take effect.
      fi
		;;
	emacs)
      replace_with_link $HOME/.emacs.d emacs.d
		;;
	git)
      replace_with_link $HOME/.gitconfig gitconfig
      replace_with_link $HOME/.git-completion.bash git-completion.bash
      replace_with_link $HOME/.git-prompt.sh git-prompt.sh
		;;
	sublime)
      replace_with_link $HOME/.config/sublime-text-3 config/sublime-text-3
      ;;
   tmux)
      replace_with_link $HOME/.tmux.conf tmux.conf
		;;
	bin)
		;;
   cmc)
      replace_with_link $HOME/.profile profile
      replace_with_link $HOME/.bash_profile profile
      replace_with_link $HOME/.profile.d/interactive/post post
      replace_with_link $HOME/.gitconfig gitconfig_cmc
      ;;
	nautilusScripts)
		;;
   *)
      echo Invalid group
      showUsage
      ;;
esac
}

showUsage()
{
	printf "
USAGE: $( basename $0) group
  
    Installs the group of configuration and plugin files for the
    following groups:

        bash :
              bashrc and bash_profile

        vim  :
              vimrc, Vundle, non-vundle plugins colors and indents, and
              runs vundleInstall

        Templates : 
              File creation templates for nautilus
              right-click->new->...

        git :
              gitconfig file plus git-completion and git-prompt.  

        sublime :
              ./config/sublime-text-3

        full :
              Installs all the preceding groups

              
"
}

# Get installDir from command line or link target.
# not a 100% robust method, look at
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
# for more detail
if [ `uname` = Darwin ] ; then
   installDir="$( cd "$( dirname $0 )" && pwd)"
elif [ `uname` = Linux ] ; then
   installDir="$( dirname "$( readlink -f "$0" )" )"
fi

if [ "$1" = full ] ; then
   installGroup bash
   installGroup vim
   installGroup Templates
   installGroup git
   installGroup sublime
   installGroup tmux
   if [ "$CMCLNG" != "" ] ; then
      installGroup cmc
   fi
elif [ "$1" != "" ] ; then
   installGroup $1
else
   echo Must specify one group or full
   showUsage
fi


# Prompt user for install dir and check it's validity

