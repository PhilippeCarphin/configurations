#!/bin/bash

function main(){
    GITHUB=$HOME/Documents/GitHub
    mkdir -p $GITHUB
    backup_originals

    setup_link_pwd
    setup_philconfig

    cd ~/.philconfig
    link-pwd link --group git
    link-pwd link --group tmux
    link-pwd link --group fish
    link-pwd link --group bash

    setup_utils
    setup_vim_and_ycm
    setup_emacs
    setup_fish
    setup_zsh

    setup_ssh

    exec fish
}


function backup_originals(){
    mv ~/.bashrc ~/.bashrc_orig
    mv ~/.bash_profile ~/.bash_profile_orig
    rmdir ~/Templates/
    mkdir ~/.vim
}


function setup_link_pwd(){
    mkdir -p ~/.local/bin
    mkdir -p ~/.local/man/man1
    git clone https://github.com/philippecarphin/link-pwd $GITHUB/link-pwd
    cd $GITHUB/link-pwd
    ./link-pwd.sh link
}


function setup_philconfig(){
    git clone https://github.com/philippecarphin/configurations ~/.philconfig
    ln -s ~/.philconfig/MISC/git-hooks/post-commit ~/.philconfig/.git/hooks/post-commit
}


function setup_utils(){
    git clone https://github.com/philippecarphin/utils ~/Documents/GitHub/utils
    cd ~/Documents/GitHub/utils/
    link-pwd link
}


function setup_vim_and_ycm(){
    sudo dnf install vim
    mkdir -p ~/.vim/bundle
    git clone https://github.com/VundleVim/Vundle.vim ~/.vim/bundle/Vundle.vim
    cd ~/.philconfig
    link-pwd link --group vim
    vim +:PluginInstall

    cd ~/.vim/bundle/YouCompleteMe
    sudo dnf install cmake gcc-c++ make python3-devel
    python3 install.py --clang-completer
}


function setup_emacs(){
    git clone https://github.com/syl20bnr/spacemacs $GITHUB/spacemacs
    ln -s $GITHUB/spacemacs ~/.emacs.d
    sudo dnf install emacs
    rm -rf ~/.emacs.d/private/
    link-pwd link --group spacemacs
    emacs --daemon
}


function setup_fish(){
    sudo dnf install fish
    chsh -s /bin/fish
    git clone https://github.com/oh-my-fish/oh-my-fish ~/.local/share/omf
    cd ~/.philconfig
    link-pwd link --group fish
    echo 'omf install agnoster' | fish
}


function setup_zsh(){
    cd ~/.philconfig
    sudo dnf install -y zsh
    git clone https://github.com/robbyrussell/oh-my-zsh ~/.oh-my-zsh
    link-pwd link --group zsh
}

function setup_ssh(){
    sudo systemctl enable sshd.service
    sudo systemctl start sshd.service
}

main
