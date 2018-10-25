
open_cmc() {
   to_open=$1
   nohup dolphin $to_open > /dev/null 2>&1 &
}

if [[ $(cmc_network) == "ec" ]] ; then
    export SPI_DIR="~/Documents/GitHub/SPI_PHIL"
    export SPOOKI_DIR="~/workspace/spooki/"
    export SPOOKI_TMPDIR="/tmp/$(whoami)/$$"
    CMC_NOTES_DIR="~/Dropbox/Notes/CMC/"
    alias gospi="cd $SPI_DIR"
    alias gospic="cd $SPI_DIR/LibTkGL/TclGeoEER/generic"
    alias gospit="cd $SPI_DIR/LibTkGL/TclGeoEER/MetObsTest"
    alias gospoo="cd $SPOOKI_DIR"
    alias makespi='(cd $SPI_DIR/LibTkGL/ ; ./makeit -spi)'
    alias quota='quota 2>/dev/null'
    alias tmuxspi='tmux new-session \; source-file ~/spi-dev.tmux'
    alias tclsh='/ssm/net/cmoe/apps/libSPI_7.12.2_ubuntu-14.04-amd64-64/TCL/bin/tclsh8.6'
    alias wish='/ssm/net/isst/maestro/1.4.3-rc4/linux26-x86-64/bin/wish'
    alias runxp='echo "$(tput setab 3)No \"$\" or \"#\" after password$(tput sgr 0)" && nohup rdesktop -g 840x525 eccmcwts3 -d ECQUEBEC -u CarphinP &'
    alias runxp-big='echo "$(tput setab 3)No \"$\" or \"#\" after password$(tput sgr 0)" && nohup rdesktop -g 1280x950 eccmcwts3 -d ECQUEBEC -u CarphinP &'
    alias open=open_cmc
    fs3=/fs/cetus3/fs3/cmd/s/afsm/pca
    alias fs3='cd $fs3'
    alias spireconf='cd $SPI_DIR/LibTkGL/TclGeoEER ; /usr/bin/autoconf2.50 || echo "spireconf failed" ; cd - >/dev/null'
    alias bash_back="sed 's/\\(exec zsh\\)/# \\1/' < ~/.bashrc > ~/.philconfig/brc ; mv ~/.philconfig/brc ~/.philconfig/bashrc"
    alias zsh_back="sed 's/\\(# \\)*\\(exec zsh\\)/\\2/' < ~/.bashrc > ~/.philconfig/brc ; mv ~/.philconfig/brc ~/.philconfig/bashrc"

    # Here it is important that there be forward slashes at the end.  This
    # changes what rsync will do.  To be sure in case I forget and remove
    # the forward slashes in the variable definitions, it is better to add
    # them here and not wonder if the variable has them.
    alias push_cmc_notes="rsync -av --cvs-exclude $CMC_NOTES_DIR/ house:$CMC_NOTES_DIR/"
    alias pull_cmc_notes="rsync -av --cvs-exclude house:$CMC_NOTES_DIR/ $CMC_NOTES_DIR/"
    # No push_notes because I want to be really sure that I don't delete anything important.
    alias pull_notes="rsync -av --cvs-exclude house:$PHIL_NOTES_DIR/ $PHIL_NOTES_DIR/"
    # alias push_notes="rsync -av --cvs-exclude $PHIL_NOTES_DIR/ house:$PHIL_NOTES_DIR/"

    alias pull_gtd="rsync -av --cvs-exclude house:$PHIL_GTD_DIR/ $PHIL_GTD_DIR/"
    # alias push_gtd="rsync -av --cvs-exclude $PHIL_GTD_DIR/ house:$PHIL_GTD_DIR/"

    alias geowork='cd ~/workspace/geomet-work'
    alias geomet='cd ~/workspace/geomet-work/geomet'
    alias geotest='cd ~/workspace/geomet-work/geomet/tests'

    spi_path=/users/dor/afsm/pca/Documents/GitHub/SPI_PHIL/eer_SPI/
    alias spi_beta='export SPI_LIB=$SSM_DEV/workspace/libSPI_7.12.2_${ORDENV_PLAT}; export SPI_PATH=$spi_path'
    alias spi++='spi_beta; $SPI_PATH/bin/SPI'
    alias emacs='/usr/bin/emacs -q'
    alias spacemacs=~/.local/bin/emacs-26.1
elif [[ $(cmc_network) == "science" ]] ; then
    echo "PHIL : On science fresh start"
    if [[ $(hostname) == *ppp* ]] ; then
       alias make='echo "$(tput setab 1)$(tput setaf 15)Do not run make on PPP$(tput sgr 0)"'
    fi
fi
