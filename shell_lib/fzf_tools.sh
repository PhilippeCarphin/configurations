#!/usr/bin/env bash #HINT

fpselect(){
    local user=${1:-$USER}
    local pid=$(pgrep -u $user "$@" | xargs -r ps -f | fzf --header-lines=1 | awk '{print $2}')
    if [[ -z ${pid} ]] ; then
        return 1
    fi
    echo ${pid}
}

fkill(){
    local pid
    if pid=$(fpselect) ; then
        kill "$@" ${pid}
    fi
}

fgdb(){
    local pid
    if pid=$(fpselect) ; then
        gdb -q -tui -p ${pid}
    fi
}

fqdel(){
    local jobid=$(fqstat "$@")
    if [[ -n ${jobid} ]] ; then
        qdel ${jobid}
    fi
}

fqstat(){
    local header_lines=2
    local a
    local fqstat_help="Type characters to narrow down
- C-p/C-n, up/down arrows: move selection up/down
- C-u/C-d: Scroll preview window up/down
- C-k: Restore normal preview"
    # Header is different when -u is used
    for a in "$@" ; do if [[ $a == -u ]] ; then header_lines=5 ; fi ; done
    qstat -w "$@" | fzf \
        --bind "ctrl-u:preview-half-page-up" \
        --bind "ctrl-d:preview-half-page-down" \
        --bind "ctrl-h:change-preview(echo \"${fqstat_help}\")" \
        --bind "ctrl-k:change-preview(echo '{}' | awk '{print \$1}' | xargs qstat -f -F json | jq --color-output ' .Jobs | .[]')" \
        --header "INFO: C-u/C-d: to scroll preview" \
        --header-lines=${header_lines} \
        --preview-window=right,40%,wrap \
        --preview="echo '{}' | awk '{print \$1}' | xargs qstat -f -F json | jq --color-output ' .Jobs | .[]'"
}

fll(){
    local dir=${1:-}
    dir=${dir%/}
    local result
    if ! result=$(ls -lhrt ${dir} | fzf | awk '{print $9}') ; then
        return 1
    fi
    echo "${dir:+${dir}/}${result}"
}

fldap(){
    local colorize="sed 's/\(.*\):\(.*\)/\x1b[1;34m\1\x1b[37m:\x1b[0;32m\2\x1b[0m/'"
    local get_uid="awk -F : '{print \$1}'"
    local search_by_uid="xargs -I UID ldapsearch -xLLL uid=UID"
    getent passwd | \
        fzf \
            --preview="echo '{}' | ${get_uid} | ${search_by_uid} | ${colorize}" \
            --preview-window=right,40%,wrap
}


fqdel(){
    local j=$(fqstat "$@" | awk '{print $1}')
    if [[ -n $j ]] ; then
        echo "qdel $j"
        qdel $j
    fi
}
