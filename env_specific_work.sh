
if [[ -n $ZSH_VERSION ]] ; then
    this_file=$0
    # echo "$0 sourced by ZSH"
elif [[ -n $BASH_VERSION ]] ; then
    # echo "${BASH_SOURCE[0]} sourced by bash"
    this_file=${BASH_SOURCE[0]}
fi

env_specific_work(){
    export LOG_LEVEL=ERROR # For r.load
    export TZ=America/Toronto
    export LANG=en_US.UTF-8
    export SSM_DEV=/home/ords/cmdd/cmds/nil000/ssm
    export GITLAB_RUNNER_SCIENCE_ORDSOUMET_KEEP_FILES='yas'
    export GONOSUMDB=gitlab.science.gc.ca
    export APP_VERBOSE_NOBOX='chu tellement tanné des grosses boîtes!'
    export MODULEPATH=~sidr000/modules${MODULEPATH:+:${MODULEPATH}}
    export PATH=$HOME/tools/rust/bin:$PATH
    export PATH=$HOME/tools/go/bin:$PATH
    export PATH=$HOME/tools/tmux-3.5a/bin:$PATH
    export PATH=$HOME/tools/node/bin:$PATH
    export PATH=$HOME/bin:$PATH
    export PATH="/home/phc001/.pixi/bin:$PATH"

    local p
    host=$(hostname -f)
    case ${host} in
        *.collab.science.gc.ca) p=http://webproxy.collab.science.gc.ca:8888/ ;;
        ppp[56]*|sc[56]*) p=http://webproxy.science.gc.ca:8888/ ;;
        *) : ;;
    esac
    # https://superuser.com/questions/944958/are-http-proxy-https-proxy-and-no-proxy-environment-variables-standard
    # https://gitlab.science.gc.ca/hpc/support/-/issues/1150#note_1230948
    if [[ -n ${p} ]] ; then
        export http_proxy=${p}
        export https_proxy=${p}
        export HTTP_PROXY=${p}
        export HTTPS_PROXY=${p}
        export no_proxy=localhost,science.gc.ca,142.98.16.0/19,142.98.32.0/20,142.98.224.0/21,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,127.0.0.0/8
    fi
}
env_specific_work ; unset $_
