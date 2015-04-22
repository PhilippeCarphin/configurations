git config --global user.name "Philippe Carphin"
git config --global user.email phil103@hotmail.com
git config --global alias.st status

# Find a way to get the folder containing the script.
# Since I do the git clone, the folder where I cloned 
# is what I want for installDir, cause what if I cloned
# somewhere else than this:
installDir=$HOME/Documents/GitHub/philconfig
# and also, since the cloning is supposed to have been
# done, the following block is useless.

if [[ ! -d "$installDir" ]]
then
    if [[ ! -L $installDir ]]
    then
        echo "Directory doesn't exist. Creating now"
        mkdir $installDir
        echo "Directory created"
    else
        echo "Directory exists"
    fi
fi

rm $HOME/.bashrc
rm $HOME/.bash_profile
rm $HOME/.vimrc
rm -rf $HOME/Templates
rm -rf $HOME/.config/sublime-text-3
rm $HOME/.gitconfig

ln -s $installDir/sublime-text-3	$HOME/.config/sublime-text-3
ln -s $installDir/bashrc 			$HOME/.bashrc
ln -s $installDir/bash_profile 		$HOME/.bash_profile
ln -s $installDir/vimrc 			$HOME/.vimrc
ln -s $installDir/Templates 		$HOME/Templates
ln -s $installDir/gitconfig 		$HOME/.gitconfig

killall nautilus

chmod 777 --recursive $installDir
