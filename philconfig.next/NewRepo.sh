# Option parsing as explained at p.132 of Classic Shell Scripting from O'Reilly
################################################################################

################################################################################
# Function showUsage() displays usage of the script
################################################################################
showUsage()
{
	printf "\033[1;32m
	    Usage: $0 [-d Config directory] 
	        -d  Choisir le dossier d'installation
			-g  Faire un git init, ajouter un .gitignore pour sublime Text
				ensuite faire un git add . et un commit.
	        -h  Aide
	 \033[0m\n"
}

################################################################################
# Option Parsing
################################################################################

installDir=$HOME/.config/MyConfigs
createGit=false
while getopts :d:g opt
do
	case $opt in
		d) 	installDir=$OPTARG
			;;
		g)	createGit=true;;
		?)	printf "\033[1;31mInvalid options \033[0m\n"
			showUsage
			exit 1
			;;
	esac
done
shift $((OPTIND - 1)) # Remove options and leave arguments

# Copier les fichiers du programme au bon endroit et donner la permission d'exécuter l'exécutable
if [[ ! -d "$installDir" ]]
then
	if [[ ! -L $installDir ]]
	then
        echo "Directory $installDir doesn't exist. Creating now"
        mkdir -p $installDir
	else
        echo "Directory $installDir exists"
	fi
fi

# Move configuration files to the directory.
mv $HOME/.config/sublime-text-3 $installDir/sublime-text-3		
mv $HOME/.bashrc				$installDir/bashrc 				
mv $HOME/.bash_profile			$installDir/bash_profile 			
mv $HOME/.vimrc					$installDir/vimrc 				
mv $HOME/Templates				$installDir/Templates 			
mv $HOME/.emacs.d				$installDir/emacs.d	 			
mv $HOME/.gitconfig				$installDir/gitconfig 			
mv $HOME/.git-completion.bash	$installDir/git-completion.bash 	

# Make links to said files.
ln -s $installDir/sublime-text-3		$HOME/.config/sublime-text-3
ln -s $installDir/bashrc 				$HOME/.bashrc
ln -s $installDir/bash_profile 			$HOME/.bash_profile
ln -s $installDir/vimrc 				$HOME/.vimrc
ln -s $installDir/Templates 			$HOME/Templates
ln -s $installDir/emacs.d	 			$HOME/.emacs.d
ln -s $installDir/gitconfig 			$HOME/.gitconfig
ln -s $installDir/git-completion.bash 	$HOME/.git-completion.bash

# Generate install script to install your own configurations on oth
pushd $installDir
echo "
installDir=\"\${BASH_SOURCE%/*}\"

# Get options, if there is no -u option (UNDO) do this
rm 		\$HOME/.bashrc
rm 		\$HOME/.bash_profile
rm 		\$HOME/.vimrc
rm -rf 	\$HOME/Templates
rm -rf 	\$HOME/.emacs.d
rm -rf 	\$HOME/.config/sublime-text-3
rm 		\$HOME/.gitconfig
rm 		\$HOME/.git-completion.bash

ln -s \$installDir/sublime-text-3		\$HOME/.config/sublime-text-3
ln -s \$installDir/bashrc 				\$HOME/.bashrc
ln -s \$installDir/bash_profile 		\$HOME/.bash_profile
ln -s \$installDir/vimrc 				\$HOME/.vimrc
ln -s \$installDir/Templates 			\$HOME/Templates
ln -s \$installDir/emacs.d	 			\$HOME/.emacs.d
ln -s \$installDir/gitconfig 			\$HOME/.gitconfig
ln -s \$installDir/git-completion.bash 	\$HOME/.git-completion.bash

killall nautilus # For templates to take effect.
chmod 777 --recursive \$installDir

# UNDOING SECTION have something like install.sh -u execute this instead of the above.
#	# Remove the link
#	rm \$HOME/.config/sublime-text-3 

#	# Put the folder back where it shoutd be
#	mv \$installDir/sublime-text-3		\$HOME/.config/sublime-text-3
#	# Do this for all the files.
" > install.sh
popd

if $createGit
then
	pushd $installDir
	git init
	echo "
sublime-text-3/Packages/User/Package Control.merged-ca-bundle
sublime-text-3/Packages/User/Package Control.user-ca-bundle

*.png
sublime-text-3/Packages/ssl-linux/
sublime-text-3/Packages/bz2/
sublime-text-3/Cache/
sublime-text-3/Index/
sublime-text-3/Packages/User/Package Control.cache/
sublime-text-3/Packages/User/Package Control.last-run
sublime-text-3/Local/Auto Save Session.sublime_session
sublime-text-3/Local/Session.sublime_session

sublime-text-3/Local/License.sublime_license
sublime-text-3/Backup/
sublime-text-3/Local/.*
*.sublime-package
sublime-text-3/Local
sublime-text-3/Packages/User/Sublimerge.sublime-license
" > .gitignore
	git add .
	git commit -m "Initial commit for tracking of configurations"
	popd
fi

