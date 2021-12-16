#!/bin/bash

p.ordenv(){
    export ORDENV_SITE_PROFILE=20191220
    export ORDENV_COMM_PROFILE=eccc/20200409
    export ORDENV_GROUP_PROFILE=eccc/cmc/1.9.3
    . /fs/ssm/main/env/ordenv-boot-20200204.sh

    export EC_ATOMIC_PROFILE_VERSION=1.11.0
    . /fs/ssm/eccc/mrd/ordenv/profile/check_profile
}

_p.require_ordenv(){
    if [ -z "$ORDENV_SETUP" ] ; then
        p.ordenv
    fi
}

p.myjobs(){
    (
        _p.require_ordenv
        jobst | grep ${USER} -n
        exec 1>/dev/null
    )
}

p.clearjobs(){
    (
        _p.require_ordenv
        for jobid in $(jobst -u $USER | grep $USER | cut -d '|' -f 1) ; do
            while jobdel ${jobid} > /dev/null 2>&1
            do
                echo "Killing job '${jobid}'"
                sleep 3
            done
            echo ""
            echo "Job '${jobid}' successfully killed."
        done
    )
}
