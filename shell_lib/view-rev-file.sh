#!/bin/bash


p.view-rev-file(){
    if [[ "${1}" != *:* ]] ; then
        echo "${FUNCNAME[0]}: Argument contains no ':'"
        return 1
    fi
    local rev=${1%%:*}
    local file_line_col=${1#*:}
    local file=${file_line_col%%:*}
    local vim_args=(-R - -c "doautocmd BufRead ${file}")
    if [[ ${file_line_col} == *:* ]] ; then
        local line_col=${file_line_col#*:}
        local line=${line_col%%:*}
        vim_args+=(+${line})
    fi
    git show ${rev}:${file} | vim "${vim_args[@]}"
}

_p.view-rev-file(){
    local cur prev words cword
    _init_completion -n : || return

    if [[ "${cur}" == *:* ]] ; then
        __git_complete_revlist_file
    else
        __git_complete_refs --sfx=:
    fi
}

complete -o nospace -F _p.view-rev-file p.view-rev-file
