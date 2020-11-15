#!/bin/bash

function git_time_since_commit() {
    # Lifted from zsh theme dogenpunk
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        return
    fi
    # Only proceed if there is actually a commit.
    if ! git log -n 1  > /dev/null 2>&1; then
        return
    fi

    # Get the last commit.
    last_commit=$(git log --pretty=format:'%at' -1 2> /dev/null)
    now=`date +%s`
    seconds_since_last_commit=$((now - last_commit))

    # Totals
    MINUTES=$((seconds_since_last_commit / 60))
    HOURS=$((seconds_since_last_commit/3600))

    # Sub-hours and sub-minutes
    DAYS=$((seconds_since_last_commit / 86400))
    SUB_HOURS=$((HOURS % 24))
    SUB_MINUTES=$((MINUTES % 60))

    if [ -z "$(git status -s 2> /dev/null)" ] ; then
        if [ "$HOURS" -gt 2 ]; then
            COLOR="$purple"
        elif [ "$MINUTES" -gt 1 ]; then
            COLOR="$orange"
        else
            COLOR="$yellow"
        fi
    fi

    # Don't use color for now but leave the code there
    # so that I can just remove this line
    COLOR=""

    if [ "$HOURS" -gt 24 ]; then
        echo "$COLOR${DAYS}d${SUB_HOURS}h${SUB_MINUTES}m"
    elif [ "$MINUTES" -gt 60 ]; then
        echo "$COLOR${HOURS}h${SUB_MINUTES}m"
    else
        echo "$COLOR${MINUTES}m"
    fi
}

function git_ps1_phil_get_info(){
    local r=""
    local b=""
    local g=$(git rev-parse --git-dir 2>/dev/null)

    if ! [ -z $g ] ; then
        _git_ps1_phil_in_repo=true
    else
        return
    fi

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

    if ! [ -z "$(git ls-files $g/.. --others --exclude-standard 2>/dev/null)" ] ; then
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
    _git_ps1_phil_time_since_commit=$(git_time_since_commit)
}

function git_ps1_phil(){
    _git_ps1_phil_in_repo=""
    _git_ps1_phil_inside_git_dir=""
    _git_ps1_phil_rebase_state=""
    _git_ps1_phil_branch=""
    _git_ps1_phil_has_untracked=""
    _git_ps1_phil_has_unstaged_changes=""
    _git_ps1_phil_has_staged_changes=""
    _git_ps1_phil_time_since_commit=""

    git_ps1_phil_get_info

    if [ -z $_git_ps1_phil_in_repo ] ; then
        return
    fi

    state=clean

    if ! [ -z $_git_ps1_phil_headless ] ; then
        state=headless
    elif [ -z $_git_ps1_phil_has_unstaged_changes ] && [ -z $_git_ps1_phil_has_staged_changes ] ; then
        state=clean
    else
        state=dirty
    fi

    case $state in
        headless)
            if ! [ -z $GIT_PS1_PHIL_HEADLESS_COLOR ] ; then
                fg_color=$GIT_PS1_PHIL_HEADLESS_COLOR
            else
                fg_color=$(tput setaf 9)
            fi
            ;;
        clean)
            if ! [ -z $GIT_PS1_PHIL_CLEAN_COLOR ] ; then
                fg_color=$GIT_PS1_PHIL_CLEAN_COLOR
            else
                fg_color=$(tput setaf 2)
            fi
            ;;
        dirty)
            if ! [ -z $GIT_PS1_PHIL_DIRTY_COLOR ] ; then
                fg_color=$GIT_PS1_PHIL_DIRTY_COLOR
            else
                fg_color=$(tput setaf 2)
            fi
            ;;
        *)
            fg_color=$(tput setaf 3)
            ;;
    esac

    if ! [ -z $_git_ps1_phil_has_untracked ] ; then
        _git_ps1_phil_untracked="[UNTRACKED FILES]"
	  fi

	  if ! [ -z $_git_ps1_phil_has_staged_changes ] || ! [ -z $_git_ps1_phil_has_unstaged_changes ] ; then
		    time_since_last_commit=" $(git_time_since_commit)"
	  fi

	  if ! [ -z $_git_ps1_phil_in_repo ] ; then
		    echo "\[$fg_color\]($_git_ps1_phil_branch)$_git_ps1_phil_untracked$time_since_last_commit\[$(tput sgr 0)\]"
	  fi
}
################################################################################
# If inside git repo, shows only the directory relative to the the repo root
# otherwise shows full pwd.
################################################################################
git_pwd() {
    if [[ $(git rev-parse --is-inside-work-tree 2>/dev/null) == true ]] ; then
        repo_dir=$(git rev-parse --show-toplevel 2>/dev/null)
        outer=$(basename $repo_dir)
        inner=$(git rev-parse --show-prefix 2>/dev/null)
        echo "${outer}/${inner}"
    else
        echo '\w'
    fi
}

################################################################################
# Different way of making PS1.  We rewrite PS1 right before it is to be
# displayed.  This is way more simple since we don't have to deal with all the
# weird ways that escaping characters can make our life difficult.
################################################################################
make_ps1(){
    previous_exit_code=$?
    if [[ $previous_exit_code == 0 ]] ; then
        pec="\[$green\] 0 \[$reset_colors\]"
    else
        pec="\[$(tput setaf 1)\] $previous_exit_code \[$reset_colors\]"
    fi

    prompt_start="\[$prompt_color\][$(whoami)@$(hostname) $(git_pwd)\[$reset_colors\]"

    git_part="$(git_ps1_phil)"
    if ! [ -z "$git_part" ] ; then
        git_part=" $git_part\[$reset_colors\]"
    fi

    last_part="\[$prompt_color\]] \$\[$reset_colors\] "

    PS1="$pec$prompt_start$git_part$last_part"
}

################################################################################
# 
################################################################################
bashrc_configure_prompt(){
    export PROMPT_COMMAND=make_ps1
    # Define colors for making prompt string.
    orange=$(tput setaf 208)
    green=$(tput setaf 2)
    yellow=$(at_cmc && tput setaf 11 || tput setaf 3)
    purple=$(tput setaf 5)
    blue=$(tput setaf 4)
    red=$(tput setaf 9)
    reset_colors=$(tput sgr 0)

    # define variables for prompt colors
    prompt_color=$purple

    GIT_PS1_PHIL_HEADLESS_COLOR=$red
    GIT_PS1_PHIL_DIRTY_COLOR=$orange
    GIT_PS1_PHIL_CLEAN_COLOR=$green

    PS2='\[$purple\] > \[$reset_colors\]'
}

bashrc_configure_prompt
