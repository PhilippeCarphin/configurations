
if [[ -n $ZSH_VERSION ]] ; then
    this_file=$0
    # echo "$0 sourced by ZSH"
elif [[ -n $BASH_VERSION ]] ; then
    # echo "${BASH_SOURCE[0]} sourced by bash"
    this_file=${BASH_SOURCE[0]}
fi

env_specific_home(){
    export LOG_LEVEL=ERROR # For r.load
    export TZ=America/Toronto
    export LANG=en_US.UTF-8
    export SSM_DEV=/home/ords/cmdd/cmds/nil000/ssm
    export GITLAB_RUNNER_SCIENCE_ORDSOUMET_KEEP_FILES='yas'
    export GONOSUMDB=gitlab.science.gc.ca
    export PATH=$HOME/tools/rust/bin:$PATH
    export PATH=$HOME/tools/go/bin:$PATH
    export PATH=$HOME/tools/tmux-3.5a/bin:$PATH
    export PATH=$HOME/bin:$PATH

    local p
    host=$(hostname -f)
    case ${host} in
        *.collab.science.gc.ca) p=http://webproxy.collab.science.gc.ca:8888/ ;;
        ppp[56]*|sc[56]*) p=http://webproxy.science.gc.ca:8888/ ;;
        *) : ;;
    esac
    if [[ -n ${p} ]] ; then
        export http_proxy=${p}
        export https_proxy=${p}
        export HTTP_PROXY=${p}
        export HTTPS_PROXY=${p}
    fi
}
env_specific_home ; unset $_
