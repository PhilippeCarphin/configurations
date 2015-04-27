# Option parsing as explained at p.132 of Classic Shell Scripting from O'Reilly
################################################################################

################################################################################
# Function showUsage() displays usage of the script
################################################################################
showUsage()
{
	printf "\033[1;32m
	    Usage: $0 [-d Config directory] 
	        -d  Choisir le dossier d'installation (no "/" at the end)
			-g  Faire un git init, ajouter un .gitignore pour sublime Text
				ensuite faire un git add . et un commit.
	        -h  Aide
	    Exemple: $0 -d ~/MyConfigs -g
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
if [ -L "$HOME/.emacs.d" ]
then 
	echo "\$HOME/.emacs.d is already a symbolic link... Aborting."
	exit 1
fi
mv $HOME/.emacs.d				$installDir/emacs.d	

# Make links to said files.
ln -s $installDir/emacs.d	 			$HOME/.emacs.d

# Generate install script to install your own configurations on other machines
pushd $installDir
echo "
	installDir=$installDir

	rm -rf 	\$HOME/.emacs.d

	ln -s \$installDir/emacs.d	 			\$HOME/.emacs.d

	chmod 777 --recursive \$installDir
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

