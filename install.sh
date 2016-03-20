#!/bin/bash
full_install()
{
	# Faire des fonctions individuelles pour chaque groupe et toutes les appeler ici.

	rm $HOME/.bashrc
	rm $HOME/.bash_profile
	rm $HOME/.vimrc
   rm -rf $HOME/.vim/colors
   rm -rf $HOME/.vim/indent
	rm -rf $HOME/Templates
	rm -rf $HOME/.emacs.d
	rm -rf $HOME/.config/sublime-text-3
	rm $HOME/.gitconfig
	rm $HOME/.git-completion.bash
   rm $HOME/.git-prompt.sh

   ln-s$installDir/sublime-text-3           $HOME/.config/sublime-text-3
   ln-s$installDir/bashrc                   $HOME/.bashrc
   ln-s$installDir/bash_profile             $HOME/.bash_profile
   ln-s$installDir/vimrc                    $HOME/.vimrc
   ln-s$installDir/vim/colors               $HOME/.vim/colors
   ln-s$installDir/vim/indent               $HOME/.vim/indent
   ln-s$installDir/Templates                $HOME/Templates
   ln-s$installDir/emacs.d                  $HOME/.emacs.d
   ln-s$installDir/gitconfig                $HOME/.gitconfig
   ln-s$installDir/git-completion.bash      $HOME/.git-completion.bash
   ln-s$installDir/git-prompt.sh            $HOME/.git-prompt.sh

	killall nautilus # For templates to take effect.

	chmod 777 --recursive $installDir
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
installDir=$HOME/Documents/GitHub/philconfig
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
