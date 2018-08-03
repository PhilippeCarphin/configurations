#!/bin/bash
replace_with_link(){
    original=$1
    target=$installDir/$2
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
    installDir="$( cd "$( dirname $0 )" > /dev/null && pwd)"
elif [ `uname` = Linux ] ; then
    installDir="$( dirname "$( readlink -f "$0" )" )"
fi

################################################################################
# Clones the spacemacs directory at the specified location
# Creates a links like so:
# ~/.emacs.d --> ~/.my_spacemacs.d --> $SPACEMACS_DIR_LOCATION/.my_spacemacs.d
# ~/.my_spacemacs.d/private --> .philconfig/.emacs.d/private
# ~/.spacemacs --> .philconfig/spacemacs
################################################################################
setup_spacemacs(){
   if [ -z SPACEMACS_DIR_LOCATION ] ; then
      echo "SPACEMACS_DIR_LOCATION must be set"
      return 1
   fi

   if ! [ -d $SPACEMACS_DIR_LOCATION ] ; then
       echo "SPACEMACS_DIR_LOCATION must be an existing directory"
       return 1
   fi

   my_spacemacs_dir=$SPACEMACS_DIR_LOCATION/.my_spacemacs.d

   if ! [ -d $my_spacemacs_dir ] ; then
      git clone https://github.com/syl20bnr/spacemacs $my_spacemacs_dir
   fi

   if [[ $my_spacemacs_dir != ~/.my_spacemacs.d ]] ; then
      [ -L ~/.my_spacemacs.d ] && rm ~/.my_spacemacs.d
      ln -s $my_spacemacs_dir ~/.my_spacemacs.d
   fi

   [ -L ~/.emacs.d ] && rm ~/.emacs.d
   ln -s ~/.my_spacemacs.d ~/.emacs.d

   replace_with_link $HOME/.my_spacemacs.d/private emacs.d/private
   replace_with_link $HOME/.spacemacs spacemacs
}

################################################################################
# Creates a links like so:
# ~/.emacs.d --> ~/.my_vanillamacs.d --> # $VANILLAMACS_DIR_LOCATION/.my_vanillamacs.d
# ~/.emacs --> ~/.my_vanillamacs --> .philconfig/vanillamacs
################################################################################
setup_vanillamacs(){
   if [ -z $VANILLAMACS_DIR_LOCATION ] ; then
       echo "VANILLAMACS_DIR_LOCATION must be set"
       return 1
   fi

   if ! [ -d $VANILLAMACS_DIR_LOCATION ] ; then
       echo "VANILLAMACS_DIR_LOCATION must be an existing directory"
       return 1
   fi

   vanillamacs_dir=$VANILLAMACS_DIR_LOCATION/.my_vanillamacs.d
   if ! [ -d $vanillamacs_dir ] ; then
      mkdir $vanillamacs_dir
   fi

   if [[ $vanillamacs_dir != ~/.my_vanillamacs.d ]] ; then
       [ -L ~/.my_vanillamacs.d ] && rm ~/.my_vanillamacs.d
       ln -s $vanillamacs_dir ~/.my_vanillamacs.d
   fi

   [ -L ~/.emacs.d ] && rm ~/.emacs.d
   ln -s ~/.my_vanillamacs.d ~/.emacs.d
   [ -L ~/.emacs ] && rm ~/.emacs
   ln -s ~/.my_vanillamacs ~/.emacs
   replace_with_link $HOME/.my_vanillamacs vanillamacs
}

source $installDir/functions

unlink_file(){
   [ -L $1 ] && rm -f $1
   [ -e $1.bak -o -d $1.bak ] && mv $1.bak $1
}

unlink_group (){
   case $1 in
      cmc)
         unlink_file $HOME/.profile
         unlink_file $HOME/.profile.d
         ;;
      zsh)
         unlink_file $HOME/.zprofile
         unlink_file $HOME/.zshrc
         unlink_file $HOME/.zshenv
         unlink_file $HOME/.zsh_custom
         ;;
      fish)
         unlink_file $HOME/.config/fish
         ;;
      bash)
         unlink_file $HOME/.bashrc
         unlink_file $HOME/.bash_profile
         ;;
      vim)
         unlink_file $HOME/.vimrc
         unlink_file $HOME/.ideavimrc
         unlink_file $HOME/.vim/colors
         unlink_file $HOME/.vim/indent
         unlink_file $HOME/.vim/plugin
         unlink_file $HOME/.vim/doc
         unlink_file $HOME/.vim/autoload
         unlink_file $HOME/.ycm_extra_conf.py
         ;;
      templates)
         unlink_file $HOME/Templates
         ;;
      spacemacs)
         unlink_file $HOME/.spacemacs
         unlink_file $HOME/.spacemacs.d
         unlink_file $HOME/.emacs.d/private
         ;;
      vanillamacs)
         unlink_file $HOME/.emacs
         ;;
      git)
         unlink_file $HOME/.gitconfig
         unlink_file $HOME/.gitignore.global
         unlink_file $HOME/.config/git
         ;;
      rsync)
         unlink_file $HOME/.cvsignore
         ;;
      sublime)
         unlink_file $HOME/.config/sublime-text-3
         ;;
      tmux)
         unlink_file $HOME/.tmux.conf
         ;;
      wakatime)
         unlink_file $HOME/.wakatime.cfg
         ;;
   esac
}

link_group(){
    case $1 in
        cmc)
            replace_with_link $HOME/.profile CMC/profile
            replace_with_link $HOME/.profile.d CMC/profile.d
            ;;
        zsh)
            replace_with_link $HOME/.zprofile zprofile
            replace_with_link $HOME/.zshrc zshrc
            replace_with_link $HOME/.zshenv zshenv
            replace_with_link $HOME/.zsh_custom zsh_custom
            ;;
        fish)
            replace_with_link $HOME/.config/fish config/fish
            ;;
        bash)
            replace_with_link $HOME/.bashrc bashrc
            replace_with_link $HOME/.bash_profile bash_profile
            ;;
        vim)
            replace_with_link $HOME/.vimrc vimrc
            replace_with_link $HOME/.ideavimrc vimrc # Pycharm uses this
            replace_with_link $HOME/.vim/colors vim/colors
            replace_with_link $HOME/.vim/indent vim/indent
            replace_with_link $HOME/.vim/plugin vim/plugin
            replace_with_link $HOME/.vim/doc vim/doc
            replace_with_link $HOME/.vim/autoload vim/autoload
            replace_with_link $HOME/.ycm_extra_conf.py ycm_extra_conf.py
            ;;
        templates)
            replace_with_link $HOME/Templates Templates
            ;;
        spacemacs)
            replace_with_link $HOME/.spacemacs spacemacs
            replace_with_link $HOME/.spacemacs.d spacemacs.d
            replace_with_link $HOME/.emacs.d/private emacs.d/private
            ;;
        vanillamacs)
            replace_with_link $HOME/.emacs vanillamacs
            ;;
        git)
            replace_with_link $HOME/.gitconfig gitconfig
            replace_with_link $HOME/.gitignore.global gitignore.global
            replace_with_link $HOME/.config/git git
            ;;
        rsync)
            replace_with_link $HOME/.cvsignore gitignore.global
            ;;
        sublime)
            replace_with_link $HOME/.config/sublime-text-3 config/sublime-text-3
            ;;
        tmux)
            replace_with_link $HOME/.tmux.conf tmux.conf
            ;;
        wakatime)
            replace_with_link $HOME/.wakatime.cfg wakatime.cfg
            ;;
        *)
            echo Invalid group $1
            showUsage
            ;;
    esac
}

showUsage()
{
    printf "
USAGE: $( basename $0) group
  
    Installs the group of configuration and plugin files for the
    following groups:

        bash :
              bashrc and bash_profile

        vim  :
              vimrc, Vundle, non-vundle plugins colors and indents, and
              runs vundleInstall

        templates : 
              File creation templates for nautilus
              right-click->new->...

        git :
              gitconfig file plus git-completion and git-prompt.  

        sublime :
              ./config/sublime-text-3

        full :
              Installs all the preceding groups

              
"
}

if [ "$1" = unlink ] ; then
   if [ "$2" = full ] ; then
      unlink_group zsh
      unlink_group fish
      unlink_group bash
      unlink_group vim
      unlink_group spacemacs
      unlink_group git
      unlink_group rsync
      unlink_group templates
      unlink_group wakatime
      unlink_group tmux
   elif [ "$2" != "" ] ; then
      unlink_group $2
   else
      echo "Must specify a group for command unlink"
      showUsage
      exit 1
   fi
   exit 0
fi

if [ "$1" = full ] ; then
    at_cmc && installGroup cmc
    link_group zsh
    link_group fish
    link_group bash
    link_group vim
    link_group spacemacs
    link_group git
    link_group rsync
    link_group templates
    link_group wakatime
    link_group tmux
elif [ "$1" != "" ] ; then
    link_group $1
else
    echo Must specify one group or full
    showUsage
fi


# Prompt user for install dir and check it's validity

