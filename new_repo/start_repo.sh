move_and_link()
{
	local source=$1
	local dest=$2
	if [ -L "$source" ]; then
		echo "Source file $source is already a link.  Not moving"
		return 1
	fi
	if [ ! -e "$source" ]; then
		echo "Source file $source doesn't exist, skipping"
		return 1
	fi
	mv $source $dest
	ln -s $dest $source
}

if [["$PWD" == "$HOME" ]]; then
	echo "It would be a bad idea to do this in your home folder"
	exit 1
fi

install_dir=$PWD
install_prompt="Initialising configuration repo in current directory

	$install_dir

Is this OK? (y/n) :"

echo -n $install_prompt
read answer
if [[ $answer != "y" ]]; then
	exit 0
fi

move_and_link $HOME/.bashrc $install_dir/bashrc
move_and_link $HOME/.bash_profile $install_dir/bash_profile
move_and_link $HOME/.vimrc $install_dir/vimrc
move_and_link $HOME/.gitconfig $install_dir/gitconfig
move_and_link $HOME/.git-completion.bash $install_dir/git-completion.bash
move_and_link $HOME/.git-prompt.sh $install_dir/git-prompt.sh
move_and_link $HOME/.tmux.conf $install_dir/tmux.conf

git init && git add . && git commit -m "Initial commit for tracking my config files"
