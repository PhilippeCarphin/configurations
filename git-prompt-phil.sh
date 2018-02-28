#!/bin/bash

function git_ps1_phil_get_info(){
	local r=""
	local b=""
	local g=$(git rev-parse --git-dir 2>/dev/null)

	if [ -f "$g/rebase-merge/interactive" ]; then
		r="|REBASE-i"
		b="$(cat "$g/rebase-merge/head-name")"
	elif [ -d "$g/rebase-merge" ]; then
		r="|REBASE-m"
		b="$(cat "$g/rebase-merge/head-name")"
	else
		if [ -d "$g/rebase-apply" ]; then
			if [ -f "$g/rebase-apply/rebasing" ]; then
				r="|REBASE"
			elif [ -f "$g/rebase-apply/applying" ]; then
				r="|AM"
			else
				r="|AM/REBASE"
			fi
		elif [ -f "$g/MERGE_HEAD" ]; then
			r="|MERGING"
		elif [ -f "$g/CHERRY_PICK_HEAD" ]; then
			r="|CHERRY-PICKING"
		elif [ -f "$g/BISECT_LOG" ]; then
			r="|BISECTING"
		fi

		b="$(git symbolic-ref HEAD 2>/dev/null)" || {
			detached=yes
			b="$(
			case "${GIT_PS1_DESCRIBE_STYLE-}" in
			(contains)
				git describe --contains HEAD ;;
			(branch)
				git describe --contains --all HEAD ;;
			(describe)
				git describe HEAD ;;
			(* | default)
				git describe --tags --exact-match HEAD ;;
			esac 2>/dev/null)" ||

			b="$(cut -c1-7 "$g/HEAD" 2>/dev/null)..." ||
			b="unknown"
			b="($b)"
		}
	fi

	if ! [ -z $g ] ; then
		_git_ps1_phil_in_repo=true
	fi

	if ! [ -z "$(git ls-files --others --exclude-standard 2>/dev/null)" ] ; then
		_git_ps1_phil_has_untracked=true
	fi

	if ! git diff --no-ext-diff --quiet --exit-code 2>/dev/null ; then
		_git_ps1_phil_has_unstaged_changes=true
	fi
	if ! git diff --staged --no-ext-diff --quiet --exit-code 2>/dev/null ; then
		_git_ps1_phil_has_staged_changes=true
	fi
	_git_ps1_phil_inside_git_dir="$(git rev-parse --is-inside-git-dir 2>/dev/null)"
	_git_ps1_phil_rebase_state=$r
	_git_ps1_phil_branch=${b##refs/heads/}
	_git_ps1_phil_headless=$detached
}

function git_ps1_phil(){
	_git_ps1_phil_in_repo=""
	_git_ps1_phil_inside_git_dir=""
	_git_ps1_phil_rebase_state=""
	_git_ps1_phil_branch=""
	_git_ps1_phil_has_untracked=""
	_git_ps1_phil_has_unstaged_changes=""
	_git_ps1_phil_has_staged_changes=""

	git_ps1_phil_get_info

	if [ -z $_git_ps1_phil_in_repo ] ; then
		return
	fi

	fg_color=$(tput setaf 3)
	if ! [ -z $_git_ps1_phil_headless ] ; then
		if ! [ -z $GIT_PS1_PHIL_HEADLESS_COLOR ] ; then
			fg_color=$GIT_PS1_PHIL_HEADLESS_COLOR
		else
			fg_color=$(tput setaf 9)
		fi
	elif [ -z $_git_ps1_phil_has_unstaged_changes ] && [ -z $_git_ps1_phil_has_staged_changes ] ; then
		if ! [ -z $GIT_PS1_PHIL_CLEAN_COLOR ] ; then
			fg_color=$GIT_PS1_PHIL_CLEAN_COLOR
		else
			fg_color=$(tput setaf 2)
		fi
	fi

	export git_ps1_phil_color=$fg_color

	if ! [ -z $_git_ps1_phil_has_untracked ] ; then
		_git_ps1_phil_untracked="[UNTRACKED FILES]"
	fi

	fg_color=$(tput setaf 3)
	if ! [ -z $_git_ps1_phil_headless ] ; then
		if ! [ -z $GIT_PS1_PHIL_HEADLESS_COLOR ] ; then
			fg_color=$GIT_PS1_PHIL_HEADLESS_COLOR
		else
			fg_color=$(tput setaf 9)
		fi
	elif [ -z $_git_ps1_phil_has_unstaged_changes ] && [ -z $_git_ps1_phil_has_staged_changes ] ; then
		if ! [ -z $GIT_PS1_PHIL_CLEAN_COLOR ] ; then
			fg_color=$GIT_PS1_PHIL_CLEAN_COLOR
		else
			fg_color=$(tput setaf 2)
		fi
	fi

	if ! [ -z $_git_ps1_phil_in_repo ] ; then
		echo "\[$fg_color\]($_git_ps1_phil_branch)$_git_ps1_phil_untracked"
	fi
}
