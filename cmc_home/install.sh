#!/bin/bash

set -euEo pipefail
shopt -s inherit_errexit

this_dir=$(cd $(dirname $0) && pwd)
this_dir_rel=${this_dir#${HOME}/}

cat >> ~/.profile <<-"EOF"
	#!/bin/bash

	if [[ $TERM == dumb ]] ; then
	    # date >> $HOME/dumb-terminal
	    if [[ -n $VSCODE_AGENT_FOLDER ]] ; then
	        source ~/.philconfig/shell_lib/vscode-extras.sh
	    fi
	    return
	fi

	if [[ -v GITLAB_RUNNER_ORDSOUMET_EXECUTOR ]] ; then
	    return
	fi

	the_profile_file=/fs/ssm/eccc/mrd/ordenv/latest/profile/ord

	# Source before profile load so I can activate it to debug ORDENV
	source ~/.philconfig/shell_lib/bash_debug.sh

	if tty -s && [[ ! -f ~/.normal_mode ]] ; then
	    # NOTE: Pipes and subshells cannot be used but process substitution
	    # >(...) can be used because only that happens in a fork.
	    # and only group commnads {...} can be used to group commands.
	    {
	        echo "the_profile_file=${the_profile_file}" >&2
	        if [[ ${the_profile_file} == */latest/* ]] ; then
	            echo "---> $(readlink -f ${the_profile_file})" >&2
	        fi

	        source ${the_profile_file}
	    } \
	         2> >( sed --unbuffered 's/^=.*/\x1b[38;5;240m\0\x1b[0m/;
	                                 s/^[^=].*/\x1b[38;5;236m\0\x1b[0m/' >&2 ) \
	         1> >( sed --unbuffered 's/.*/\x1b[31mSTDOUT: \0\x1b[0m/' >&2 )
	    trap -- "printf '\033[38;5;240m'
	            $(eval arr=("$(trap -p EXIT)") ; echo "${arr[2]}")
	            printf '\033[0m'" EXIT
	    cat ~/.philconfig/cmc_home/tux.txt >&2
	else
	    source ${the_profile_file} >&2

	fi
EOF

mkdir -p ~/.profile.d/default
cat >> ~/.profile.d/default/post <<-EOF
source ~/.philconfig/cmc_home/dot-profile
EOF
