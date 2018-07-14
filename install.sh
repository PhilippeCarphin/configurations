#!/bin/bash
replace_with_link(){
   original=$1
   target=$installDir/$2
   mkdir -p $(dirname $original)
   if [ -L $original ] ; then
      rm $original
   elif [ -e $original -o -d $original ] ; then
      mv $original $original.bak
   fi
   ln -s $target $original
}

sudo_replace_with_file(){
	original_file=$1
	my_file=$2
	if ! grep PHILCONFIG $file ; then
		sudo mv $original_file $my_file.phil.bak
	fi
	sudo cp $my_file $original_file
}

installGroup() {
case $1 in
   utils)
      if ! [ -d ~/Documents/GitHub ] ; then
         mkdir ~/Documents/GitHub
      fi
      git clone https://github.com/PhilippeCarphin/utils ~/Documents/GitHub/utils
      ;;
   cmc)
      replace_with_link $HOME/.profile CMC/profile
      replace_with_link $HOME/.profile.d CMC/profile.d
      ;;
	zsh)
		replace_with_link $HOME/.zprofile zprofile
		replace_with_link $HOME/.zshrc zshrc
		replace_with_link $HOME/.zshenv zshenv
		replace_with_link $HOME/.zsh_custom zsh_custom
      git clone https://github.com/robbyrussell/oh-my-zsh ~/.oh-my-zsh
		;;
    fish)
        replace_with_link $HOME/.config/fish config/fish
        ;;
	bash)
      replace_with_link $HOME/.bashrc bashrc
      replace_with_link $HOME/.bash_profile bash_profile
	  replace_with_link $HOME/.github-aliases github-aliases
	  replace_with_link $HOME/.functions functions
	  replace_with_link $HOME/.general-aliases general-aliases
	  replace_with_link $HOME/.envvars envvars
		;;
	root-bashrc)
		sudo_replace_with_file /root/.bashrc root_bashrc
		;;
	root-zshrc)
		sudo_replace_with_file /root/.zshrc root_zshrc
		sudo cp -R $HOME/.oh-my-zsh /root/.oh-my-zsh
		;;
	logging)
	  replace_with_link $HOME/.local/bin/SUDO SUDO
	  if [[ $(uname) == Darwin ]] ; then
		  replace_with_link $HOME/.local/bin/BREW BREW
	  fi
		;;
	vim)
      replace_with_link $HOME/.vimrc vimrc
	  replace_with_link $HOME/.ideavimrc vimrc # Pycharm uses this
      replace_with_link $HOME/.vim/colors vim/colors
      replace_with_link $HOME/.vim/indent vim/indent
      replace_with_link $HOME/.vim/plugin vim/plugin
      replace_with_link $HOME/.vim/doc vim/doc
      replace_with_link $HOME/.vim/autoload vim/autoload
	  replace_with_link $HOME/.ycm_extra_conf.py ycm_extra_conf.py
	  # Note that the vundle stuff that goes in the fimrc file is already there
	  # in my  vimrc file.  Otherwise, one can use the vundle_install.sh
	  # from my tests repository (https://github.com/PhilippeCarphin/tests
	  # in the BASH_tests directory).
      if [ ! -e $HOME/.vim/bundle/Vundle.vim ] ; then
         git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
      fi
      vim +:PluginInstall # for the plugins managed by vundle to be installed.
		;;
	templates)
      replace_with_link $HOME/Templates Templates
      if [ `uname` = Linux ] ; then
         echo "$0 (group=templates) : killing nautilus"
         killall nautilus # For templates to take effect.
      fi
		;;
	emacs)
      replace_with_link $HOME/.spacemacs spacemacs
		;;
	git)
      replace_with_link $HOME/.gitconfig gitconfig
      replace_with_link $HOME/.git-completion.bash git-completion.bash
      replace_with_link $HOME/.git-prompt.sh git-prompt.sh
      replace_with_link $HOME/.git-prompt-phil.sh git-prompt-phil.sh
	  replace_with_link $HOME/.gitignore.global gitignore.global
	  replace_with_link $HOME/.config/git git
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
  wakatime)
      replace_with_link $HOME/.wakatime.cfg wakatime.cfg
      ;;
   *)
      echo Invalid group $1
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

        templates : 
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
   installGroup zsh
   installGroup fish
   installGroup vim
   installGroup templates
   installGroup git
   installGroup sublime
   installGroup tmux
   installGroup logging
   installGroup emacs
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

