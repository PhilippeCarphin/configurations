
p.setup_spooki(){
    p.ordenv
    local setup_file=~/spooki-build/setup_spooki_dev_environment.sh
    if [ -f $setup_file ] ; then
       _p.do_maybe_redirect source $setup_file
    else
       _p.do_maybe_redirect source ~/workspace/spooki/SETUP_ubuntu-18.04-amd64-64
    fi
    alias spooki-dev='$SPOOKI_BIN_PATH/spooki_run'
}
