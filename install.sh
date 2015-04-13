git config --global user.name "Philippe Carphin"
git config --global user.email phil103@hotmail.com
git config --global alias.st status

installDir=$HOME/philconfig/

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

git clone https://github.com/PewMcDaddy/configurations.git $installDir
rm $HOME/.bashrc
rm $HOME/.vimrc
rm -rf $HOME/Templates
rm -rf $HOME/.config/sublime-text-3
rm $HOME/.gitconfig

ln -s $installDir/sublime-text-3 $HOME/.config/sublime-text-3
ln -s $installDir/bashrc 		 $HOME/.bashrc
ln -s $installDir/vimrc 		 $HOME/.vimrc
ln -s $installDir/Templates 	 $HOME/Templates
ls -s $installDir/gitconfig 	 $HOME/.gitconfig

chmod 777 --recursive $HOME/philconfig