
env_specific_home(){
    export LOG_LEVEL=ERROR # For r.load
    export TZ=America/Toronto
    export LANG=en_US.UTF-8
    export SSM_DEV=/home/ords/cmdd/cmds/nil000/ssm
    export GITLAB_RUNNER_SCIENCE_ORDSOUMET_KEEP_FILES='yas'
    export GONOSUMDB=gitlab.science.gc.ca
    export PATH=$HOME/tools/rust/bin:$PATH
    export PATH=$HOME/tools/go/bin:$PATH
    export PATH=$HOME/bin:$PATH

    local p=http://webproxy.science.gc.ca:8888/
    export http_proxy=${p}
    export https_proxy=${p}
    export HTTP_PROXY=${p}
    export HTTPS_PROXY=${p}
}
env_specific_home ; unset $_
