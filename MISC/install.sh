#!/bin/bash
replace_with_link(){
    original=$1
    target=$this_dir/$2
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

if [ `uname` = Darwin ] ; then
    this_dir="$( cd "$( dirname $0 )" > /dev/null && pwd)"
elif [ `uname` = Linux ] ; then
    this_dir="$( dirname "$( readlink -f "$0" )" )"
fi

source $this_dir/FILES/functions

unlink_file(){
    [ -L $1 ] && rm -f $1
    [ -e $1.bak -o -d $1.bak ] && mv $1.bak $1
}

link_or_unlink(){
    if [[ $action == link ]] ; then
        replace_with_link $1 $2
    elif [[ $action == unlink ]] ; then
        unlink_file $1
    fi
}

link_or_unlink_group(){
    case $1 in
        bash)
            link_or_unlink $HOME/.bashrc bashrc
            link_or_unlink $HOME/.bash_profile bash_profile
            ;;
        cmc)
            link_or_unlink $HOME/.profile CMC/profile
            link_or_unlink $HOME/.profile.d CMC/profile.d
            ;;
        fish)
            link_or_unlink $HOME/.config/fish config/fish
            ;;
        git)
            link_or_unlink $HOME/.gitconfig gitconfig
            link_or_unlink $HOME/.gitignore.global gitignore.global
            link_or_unlink $HOME/.config/git git
            ;;
        rsync)
            link_or_unlink $HOME/.cvsignore gitignore.global
            ;;
        spacemacs)
            link_or_unlink $HOME/.spacemacs spacemacs
            link_or_unlink $HOME/.spacemacs.d spacemacs.d
            if [ -d ~/.emacs.d ] ; then 
                link_or_unlink $HOME/.emacs.d/private emacs.d/private
            else
                echo "Group spacemacs : could not link $HOME/.emacs.d/private because $HOME/.emacs.d does not exist"
            fi
            ;;
        sublime)
            link_or_unlink $HOME/.config/sublime-text-3 config/sublime-text-3
            ;;
        templates)
            link_or_unlink $HOME/Templates Templates
            ;;
        tmux)
            link_or_unlink $HOME/.tmux.conf tmux.conf
            ;;
        vim)
            link_or_unlink $HOME/.vimrc vimrc
            link_or_unlink $HOME/.ideavimrc vimrc # Pycharm uses this
            link_or_unlink $HOME/.vim/colors vim/colors
            link_or_unlink $HOME/.vim/indent vim/indent
            link_or_unlink $HOME/.vim/plugin vim/plugin
            link_or_unlink $HOME/.vim/doc vim/doc
            link_or_unlink $HOME/.vim/autoload vim/autoload
            link_or_unlink $HOME/.ycm_extra_conf.py ycm_extra_conf.py
            ;;
        wakatime)
            link_or_unlink $HOME/.wakatime.cfg wakatime.cfg
            ;;
        zsh)
            link_or_unlink $HOME/.zprofile zprofile
            link_or_unlink $HOME/.zshrc zshrc
            link_or_unlink $HOME/.zshenv zshenv
            link_or_unlink $HOME/.zsh_custom zsh_custom
            ;;
        *)
            echo Invalid group $1
            show_usage
            ;;
    esac
}

show_usage()
{
    printf "
USAGE: $( basename $0) [link|unlink] group

    Links or unlinks the group of configuration and plugin files for the
    following groups:

        cmc : .profile .profile.d

        bash : .bashrc .bash_profile

        zsh : .zshrc .zshenv .zprofile, .zsh_custom

        vim  : .vimrc .ideavimrc .vim/{indent colors plugin doc autoload} .ycm_extra_conf.py

        templates : Templates directory

        git : .gitconfig .config/git .gitignore.global

        emacs : .spacemacs and .spacemacs.d

        tmux : .tmux.conf

        sublime : .config/sublime-text-3

        wakatime : .wakatime.cfg

        full : links or unlinks all the preceding groups

"
}

action=$1
if [ "$2" == "full" ] ; then
    link_or_unlink_group cmc
    link_or_unlink_group bash
    link_or_unlink_group fish
    link_or_unlink_group git
    link_or_unlink_group rsync
    link_or_unlink_group spacemacs
    link_or_unlink_group sublime
    link_or_unlink_group templates
    link_or_unlink_group tmux
    link_or_unlink_group wakatime
    link_or_unlink_group zsh
elif ! [ -z $2 ] ; then
    link_or_unlink_group $2
else
    echo "No group specified"
    show_usage
fi


# Prompt user for install dir and check it's validity

