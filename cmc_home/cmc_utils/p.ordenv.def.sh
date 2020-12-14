#!/bin/bash

p.ordenv(){
    source /home/phc001/.philconfig/cmc_home/cmc_utils/ordenv.sh
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
