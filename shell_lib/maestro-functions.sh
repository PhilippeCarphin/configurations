
function p.clear-exp-sitestore(){
    rm -rf ~/site5/rm_hind_seas_hub/work/*
}

function xflow(){
    if ! [[ -d hub ]] && [[ -d listings ]] && [[ -L EntryModule ]] ; then
        printf "phil xflow adapter: \033[1;31mERROR\033[0m: Please run inside an experiment\n"
        return 1
    fi
    printf "\033[1;33mSetting SEQ_EXP_HOME before starting xflow because otherwise I get errors when using Right-click->Info->Evaluated node config\033[0m\n"
    SEQ_EXP_HOME=$PWD command xflow
}

