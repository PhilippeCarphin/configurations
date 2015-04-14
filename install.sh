git config --global user.name "Philippe Carphin"
git config --global user.email phil103@hotmail.com
git config --global alias.st status

installDir=$HOME/Documents/GitHub/philconfig

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