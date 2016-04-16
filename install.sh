#!/bin/bash
full_install()
{
	# Faire des fonctions individuelles pour chaque groupe et toutes les appeler ici.

   # TODO: For each of these, if the thing to remove is not a link, rename it
   # from XXXX to XXXX.bak and move it to one specific directory.

   # TODO: Allow to specify the installation directory, or just make installDir
   # be wherever the stuff is. I can find out using PWD I think.  But if the
   # script is run from ~/Documents/GitHub by typing
   #        $ ./philconfig/install.sh -f 
   # then PWD alone won't work.  But the combination of PWD and $0 is all the
   # information I need.
   # 
   # What if the script is somewhere different from where the other files are?
   # NO! We're not doing that.  You can put everything where ever you want, but
   # leave everything together.
   # 
   # What if the script is used through a link.  God damnit!  Ok, well that's a
   # possibility I'll look into some other time.

	rm $HOME/.bashrc
   rm $HOME/.profile.d/interactive/post
	rm $HOME/.bash_profile
	rm $HOME/.vimrc
   rm -rf $HOME/.vim/colors
   rm -rf $HOME/.vim/indent
   rm -rf $HOME/.vim/plugin
	rm -rf $HOME/Templates
	rm -rf $HOME/.emacs.d
	rm -rf $HOME/.config/sublime-text-3
	rm $HOME/.gitconfig
	rm $HOME/.git-completion.bash
   rm $HOME/.git-prompt.sh
   rm $HOME/.tmux.conf

   ln -s $installDir/sublime-text-3           $HOME/.config/sublime-text-3
   ln -s $installDir/bashrc                   $HOME/.bashrc
   # For CMC 
   ln -s $installDir/bashrc                   $HOME/.profile.d/interactive/post
   ln -s $installDir/bash_profile             $HOME/.bash_profile
   ln -s $installDir/vimrc                    $HOME/.vimrc
   ln -s $installDir/vim/colors               $HOME/.vim/colors
   ln -s $installDir/vim/indent               $HOME/.vim/indent
   ln -s $installDir/vim/plugin               $HOME/.vim/plugin
   ln -s $installDir/Templates                $HOME/Templates
   ln -s $installDir/emacs.d                  $HOME/.emacs.d
   ln -s $installDir/gitconfig                $HOME/.gitconfig
   ln -s $installDir/git-completion.bash      $HOME/.git-completion.bash
   ln -s $installDir/git-prompt.sh            $HOME/.git-prompt.sh
   ln -s $installDir/tmux.conf                $HOME/.tmux.conf

   if [ ! -e $HOME/.vim/bundle/Vundle.vim ] ; then
      git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
   fi
   vim +:PluginInstall # for the plugins managed by vundle to be installed.

   if [ `uname` = Linux ] ; then
      killall nautilus # For templates to take effect.
   fi

}

showUsage()
{
	printf "\033[1;32m
	    Usage: $0 [-f] [-m] [-s group] [-d]
	        -f  Full install
	        -m  Move existing config files to config folder
	        -s <group> Install a specific group.
	        	bash
	        	vim
	        	Templates
	        	emacs
	        	git
	        	sublime
	        	bin
	        	nautilusScripts
	        -d  set install directory
	        -h  Aide
	    Example 
	    	./install.sh -s git
	    	./install.sh -f
	 \033[0m\n"
}

REPLACE=true

# Get installDir from command line or link target.
# not a 100% robust method, look at
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
# for more detail
installDir="$( dirname "$( readlink -f "$0" )" )"

while getopts :fbs:h opt 
do
	case $opt in
		f) 	full_install
			exit 1 ;;
		m) 	move_install
			exit 1 ;;
		s)  group=$OPTARG ;;
		h)	showUsage
			exit 1 ;;
		?)	printf "\033[1;31mInvalid options \033[0m\n"
			showUsage
			exit 1
			;;
	esac
done
shift $((OPTIND - 1))

# Prompt user for install dir and check it's validity

case ${group} in
	bash)
		rm $HOME/.bashrc
		rm $HOME/.bash_profile
		ln -s $installDir/bashrc 				$HOME/.bashrc
		ln -s $installDir/bash_profile 			$HOME/.bash_profile
		;;
	vim)
		rm $HOME/.vimrc
		ln -s $installDir/vimrc 				$HOME/.vimrc
		;;
	Templates)
		rm -rf $HOME/Templates
		ln -s $installDir/Templates 			$HOME/Templates
		;;
	emacs)
		rm -rf $HOME/.emacs.d
		ln -s $installDir/emacs.d	 			$HOME/.emacs.d
		;;
	git)
		rm $HOME/.gitconfig
		rm $HOME/.git-completion.bash
		ln -s $installDir/gitconfig 			$HOME/.gitconfig
		ln -s $installDir/git-completion.bash 	$HOME/.git-completion.bash
		;;
	sublime)
		rm -rf $HOME/.config/sublime-text-3
		ln -s $installDir/sublime-text-3		$HOME/.config/sublime-text-3
		;;
	bin)
		
		;;
	nautilusScripts)
		
		;;
esac # YARK! Sérieusement! 
