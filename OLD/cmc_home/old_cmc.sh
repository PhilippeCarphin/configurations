

   export SEQ_TRACE_LEVEL=1:TL_FULL_TRACE
   case $- in
      *i*)
         export domain="/users/dor/afsi/phc/Testing/testdomain"
         export CMCLNG=english
         echo "   Loading CMC commands "
         . ssmuse-sh -d cmoi/apps/git/20150526
         . ssmuse-sh -d cmoi/apps/git-procedures/20150622
         if [ `hostname` == artanis ] ; then
            echo "      ssm'ing maestro 1.5 development version"
            maestro=$domain
         else
            echo "      ssm'ing maestro 1.5.0-rc7"
            maestro=/ssm/net/isst/maestro/1.5.0-rc7
         fi
         . ssmuse-sh -d $maestro
         export SEQ_MAESTRO_SHORTCUT=". ssmuse-sh -d $maestro"
         alias runxp=/users/dor/afsi/dor/ovbin/i686/runxp
         alias xflow_overviewSuites="xflow_overview -suites ~afsiops/xflow.suites.xml;echo allo"
         alias runxp_phil='/usr/bin/rdesktop -a 16 -r sound:local -g 1500x1100 eccmcwts3'
         alias cmc_origin='cd /home/ordenv/GIT-DEPOTS/impl/isst'
         alias dor_origin='cd /home/ops/afsi/dor/tmp/maestro_depot'
         # Example error line: mtest_main.c:479:4 error expected ';' before 'if' ...
         # -> anything, then some digits, then a ':', some digits, a ':', then a space, then 'error'
         alias emake="make 2>&1 | grep '.*[0-9]\+:[0-9]\+: error' --color=always --after-context=4"
         alias wmake='make 2>&1 | grep '.*warning' --color=always --after-context=4'
         alias nmake='make 2>&1 | grep '.*note' --color=always --after-context=4'


         if [ `hostname` != artanis ] ; then
            alias mcompile='export SEQ_EXP_HOME=$HOME/Documents/Experiences/compilation && maestro -d 20160119000000 -n /compile -s submit -f continue'
            alias xcompile='export SEQ_EXP_HOME=$HOME/Documents/Experiences/compilation && xflow'
         fi

         . ssmuse-sh -d $maestro
         export SEQ_MAESTRO_SHORTCUT=". ssmuse-sh -d $maestro"
         if [ `which git` = /usr/bin/git ] ; then
            # To protect against using a bad version of git.
            alias git="echo bad version of git"
         fi
         ;;
      *)
         ;;
   esac
ssmdev(){
   maestro=$domain
   . ssmuse-sh -d $maestro
   export SEQ_MAESTRO_SHORTCUT=". ssmuse-sh -d $maestro"
}

open_cmc() {
   to_open=$1
   nohup dolphin $to_open > /dev/null 2>&1 &
}

function ts(){
    if [ -e ./toScience ] ; then
        ./toScience phc001
    fi
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
    alias buildspoo="cd ~/hall1_phil/spooki/build"
    alias makespi='(cd $SPI_DIR/LibTkGL/ ; ./makeit -spi)'
    alias quota='quota 2>/dev/null'
    alias tmuxspi='tmux new-session \; source-file ~/spi-dev.tmux'
    alias tclsh='/ssm/net/cmoe/apps/libSPI_7.12.2_ubuntu-14.04-amd64-64/TCL/bin/tclsh8.6'
    alias wish='/ssm/net/isst/maestro/1.4.3-rc4/linux26-x86-64/bin/wish'
    alias open=open_cmc
    export fs3=/fs/cetus3/fs3/cmd/s/afsm/pca
    alias fs3='cd $fs3'
    alias spireconf='cd $SPI_DIR/LibTkGL/TclGeoEER ; /usr/bin/autoconf2.50 || echo "spireconf failed" ; cd - >/dev/null'
    alias bash_back="sed 's/\\(exec zsh\\)/# \\1/' < ~/.bashrc > ~/.philconfig/brc ; mv ~/.philconfig/brc ~/.philconfig/bashrc"

    # Here it is important that there be forward slashes at the end.  This
    # changes what rsync will do.  To be sure in case I forget and remove
    # the forward slashes in the variable definitions, it is better to add
    # them here and not wonder if the variable has them.
    alias push_cmc_notes="rsync -av --cvs-exclude $CMC_NOTES_DIR/ house:$CMC_NOTES_DIR/"
    alias pull_cmc_notes="rsync -av --cvs-exclude house:$CMC_NOTES_DIR/ $CMC_NOTES_DIR/"
    # No push_notes because I want to be really sure that I don't delete anything important.
    alias pull_notes="rsync -av --cvs-exclude apt:/Users/pcarphin/Dropbox/Notes/Notes_BUCKET/ $HOME/Dropbox/Notes/Notes_BUCKET/"
    # alias push_notes="rsync -av --cvs-exclude $PHIL_NOTES_DIR/ house:$PHIL_NOTES_DIR/"

    alias pull_gtd="rsync -av --cvs-exclude house:$PHIL_GTD_DIR/ $PHIL_GTD_DIR/"
    # alias push_gtd="rsync -av --cvs-exclude $PHIL_GTD_DIR/ house:$PHIL_GTD_DIR/"

    alias geowork='cd ~/workspace/geomet-work'
    alias geomet='cd ~/workspace/geomet-work/geomet'
    alias geotest='cd ~/workspace/geomet-work/geomet/tests'

    spi_path=/users/dor/afsm/pca/Documents/GitHub/SPI_PHIL/eer_SPI/
    alias spi_beta='export SPI_LIB=$SSM_DEV/workspace/libSPI_7.12.2_${ORDENV_PLAT}; export SPI_PATH=$spi_path'
    alias spi++='spi_beta; $SPI_PATH/bin/SPI'
    # alias emacs='/usr/bin/emacs -q'
    # alias spacemacs=~/.local/bin/emacs-26.1
elif [[ $(cmc_network) == "science" ]] ; then
    if [[ $(hostname) == *ppp* ]] ; then
       alias make='echo "$(tput setab 1)$(tput setaf 15)Do not run make on PPP$(tput sgr 0)"'
    fi
fi
