#!/bin/bash

p.ordenv(){
    source ~/.philconfig/cmc_home/cmc_utils/ordenv.sh
}

_p.require_ordenv(){
    if [ -z "$ORDENV_SETUP" ] ; then
        p.ordenv
    fi
}
