#!/usr/bin/env bash
# vim: noet:ts=8:sw=8:sts=8:listchars=lead\:x,trail\:y,tab\:\ \ :
#
# Adds to git-completion.bash by overriding `_git_clone` and `_git_remote`
# to give URL completion that is configurable in the gitconfig file.
#
# Domain suggestions are configured with
#
#	[gitcomp]
#		domains = github.com gitlab.com
#		remoteNames = origin upstream
# And username suggestions are configured per domain with
#	[gitcomp-domain "github.com"]
#		users = torvalds philippecarphin bminor ECCC_ASTD_MRD
#	[gitcomp-domain "gitlab.com"]
#		users = philippecarphin gitlab-org

if ! declare -F _git_clone &>/dev/null ; then
	echo "git-completion needs to be sourced first because this defines overrides for two of the functions it defines" >&2
	return 1
fi

# Copied from git-completion.bash with additions marked with '# EXTRA'
_git_clone ()
{
	case "$prev" in
	-c|--config)
		__git_complete_config_variable_name_and_value
		return
		;;
	esac
	case "$cur" in
	--config=*)
		__git_complete_config_variable_name_and_value \
			--cur="${cur##--config=}"
		return
		;;
	--*)
		__gitcomp_builtin clone
		return
		;;
	*)                                           # EXTRA
		if ! __gitextras_has_url ; then        # EXTRA
			__gitextras_complete_url ${cur} -d    # EXTRA
		fi                                   # EXTRA
		return                               # EXTRA
		;;                                   # EXTRA
	esac
}

# Copied from git-completion.bash with additions marked with '# EXTRA'
_git_remote ()
{
	local subcommands="
		add rename remove set-head set-branches
		get-url set-url show prune update
		"
	local subcommand="$(__git_find_on_cmdline "$subcommands")"
	if [ -z "$subcommand" ]; then
		case "$cur" in
		--*)
			__gitcomp_builtin remote
			;;
		*)
			__gitcomp "$subcommands"
			;;
		esac
		return
	fi

	case "$subcommand,$cur" in
	add,--*)
		__gitcomp_builtin remote_add
		;;
	add,*)
		__gitextras_add_or_set-url  # EXTRA
		;;
	set-head,--*)
		__gitcomp_builtin remote_set-head
		;;
	set-branches,--*)
		__gitcomp_builtin remote_set-branches
		;;
	set-head,*|set-branches,*)
		__git_complete_remote_or_refspec
		;;
	update,--*)
		__gitcomp_builtin remote_update
		;;
	update,*)
		__gitcomp "$(__git_remotes) $(__git_get_config_variables "remotes")"
		;;
	set-url,--*)
		__gitcomp_builtin remote_set-url
		;;
	set-url,*)                                 # EXTRA
		__gitextras_add_or_set-url  # EXTRA
		;;
	get-url,--*)
		__gitcomp_builtin remote_get-url
		;;
	prune,--*)
		__gitcomp_builtin remote_prune
		;;
	*)
		__gitcomp_nl "$(__git_remotes)"
		;;
	esac
}

_git_submodule ()
{
	__git_has_doubledash && return

	local subcommands="add status init deinit update set-branch set-url summary foreach sync absorbgitdirs"
	local subcommand="$(__git_find_on_cmdline "$subcommands")"
	if [ -z "$subcommand" ]; then
		case "$cur" in
		--*)
			__gitcomp "--quiet"
			;;
		*)
			__gitcomp "$subcommands"
			;;
		esac
		return
	fi

	case "$subcommand,$cur" in
	add,--*)
		__gitcomp "--branch --force --name --reference --depth"
		;;
	add,*)
		__gitextras_add_or_set-url
		;;
	status,--*)
		__gitcomp "--cached --recursive"
		;;
	deinit,--*)
		__gitcomp "--force --all"
		;;
	update,--*)
		__gitcomp "
			--init --remote --no-fetch
			--recommend-shallow --no-recommend-shallow
			--force --rebase --merge --reference --depth --recursive --jobs
		"
		;;
	set-branch,--*)
		__gitcomp "--default --branch"
		;;
	summary,--*)
		__gitcomp "--cached --files --summary-limit"
		;;
	foreach,--*|sync,--*)
		__gitcomp "--recursive"
		;;
	*)
		;;
	esac
}

__gitextras_has_url(){
	# cword is the index of the word that has the cursor in it which is
	# also equal to the number of words before the index that has the
	# cursor.
	for w in "${words[@]:0:cword}" ; do
		case "$w" in
			git@*:*|https://*/*) return 0 ;;
		esac
	done
	return 1
}

__gitextras_add_or_set-url(){
	# The URLs can appear in different places
	# git submodule add <repo> [<path>]
	# git remote add <name> <url>
	# git remote set-url <name> <url>
	# So we count from the end how many words we have go through until
	# we reach the subcommand.  This will fail if there are options
	local words_after_subcommand=0
	local i=${cword}
	while (( i > 0 )) ; do
		case ${words[i]} in
			add|set-url) break ;;
			*) ((words_after_subcommand++)) ;;
		esac
		((i--))
	done
	compopt +o default +o bashdefault
	case "${command},${subcommand},${words_after_subcommand}" in
		*,*,0) ;; # Can't happen

		# git remote add <new-name> <URL>
		remote,add,1) compopt +o nospace ; COMPREPLY+=( $(compgen -W "$(git config --get-all gitcomp.remoteNames)" -- "${cur}") ) ;;

		remote,add,2) __gitextras_complete_url ;;

		# git remote set-url <existing-remote> <URL>
		remote,set-url,1) __gitcomp_nl "$(__git_remotes)" ;;
		remote,set-url,2) __gitextras_complete_url ;;

		# git submodule add <repository> [<path>]:
		# <repository> can also be a relative URL starting with ./ or ../
		submodule,add,1) __gitextras_complete_url ;;
		submodule,add,2) compopt -o default ;;
		# git submodule set-url <path> <newurl>
		submodule,set-url,1) compopt -o default ;;
		submodule,set-url,2) __gitextras_complete_url ;;
	esac
}

__gitextras_complete_url(){
	compopt -o nospace
	local url=${1:-${cur}}
	local dir=${2}
	case "${url}" in
		..*|/*|.*)
			_filedir -d
			if [[ ${dir} != "-d" ]] ; then
				__gitextras_complete_relative_url
			fi
			return ;;
		git@*:*/*|https://*/*/)
			# Complete project names
			return ;;
		git@*:*)
			# Complete usernames for git@<domain>:___
			domain_user=${url#git@} ; domain=${domain_user%%:*} ; user=${domain_user##*:}
			COMPREPLY+=( $(compgen -S / -W "$(git config --get-all gitcomp-domain.${domain}.users)" -- "${user}") )
			;;
		git@*)
			# Complete domains for git@___
			domain=${url#git@}
			COMPREPLY+=( $(compgen -P "git@" -S : -W "$(git config --get-all gitcomp.domains)" -- "${domain}") )
			;;
		https://*/*)
			# Complete usernames for https://<domain>/___
			domain_user=${url#https://} ; user=${domain_user##*/} ; domain=${domain_user%%/${user}}
			COMPREPLY+=( $(compgen -P "//${domain}/" -S / -W "$(git config --get-all gitcomp-domain.${domain}.users)" -- "${user}") )
			;;
		https://*)
			# Complete domains for https://___
			domain=${url#https://}
			COMPREPLY+=( $(compgen -P "//" -S / -W "$(git config --get-all gitcomp.domains)" -- "${domain}") )
			;;
		*)
			# compopt -o filenames
			# _filedir -d
			# __gitextras_complete_relative_url
			compopt +o filenames
			# Complete the protocol
			COMPREPLY+=( $(compgen -W "https:// git@" -- "${url}") )
			if [[ "${command}" == submodule ]] ; then
				COMPREPLY+=( $(compgen -W "../" -- "${url}") )
			fi
			;;
	esac
}

__gitextras_complete_relative_url(){
	: This is gettting a bit nuts and I thing we can live without completion
	# - Special cases
	#   - ${cur} == ".." -> complete to "../"
	#   - ${cur} == "../.." -> complete to "../../"
	case ${cur} in
		..) COMPREPLY+=(../) ; return ;;
		../) ;;
		../..) COMPREPLY+=(../../) ; return ;;
		# ../../../<domain>/<user>/<project> doesn't even work
		# so I wasted 15 minutes coming up with completion for it
		../../..) COMPREPLY+=(../../../) ; return ;;
		../../*) ;;
		*) return ;; # ../ : completing projects of the same user/group
	esac
	# Assume relative path is ../../___
	# TODO: Completing relative URLs requires knowing what the URL's are
	# relative to and it may not be the URL of the remote 'origin', and for that
	# matter, the repo may not even have a remote named 'origin'
	local abs_url=$(git remote get-url origin 2>/dev/null)
	local domain
	local user
	case ${abs_url} in
		git@*:*)
			domain_user=${abs_url#git@}
			domain=${domain_user%:*}
			;;
		https://*/*)
			domain_user=${abs_url#https://}
			domain=${domain_user%/*}
			;;
	esac

	case ${cur} in
		../../../*/*)
			domain_user=${cur#../../../} ; domain=${domain_user%/*} ; user=${domain_user#*/}
			COMPREPLY+=( $(compgen -P ../../../${domain}/ -W "$(git config --get-all gitcomp-domain.${domain}.users)" -- "${user}"))
			;;
		../../../*)
			COMPREPLY+=( $(compgen -P ../../../ -W "$(git config --get-all gitcomp.domains)" -- "${cur#../../../}"))
			;;
		../../*)
			COMPREPLY+=( $(compgen -P ../../ -W "$(git config --get-all gitcomp-domain.${domain}.users)" -- "${cur#../../}"))
			;;
	esac

	# - Find out the remote R URL of the pushdefault remote of the current branch
	#   ex: R = git@github.com:philippecarphin/utils
	# - Normalize ${R}/${relative_url} so the .. cancels a token
	#   ex A : relative_url = ../
	#   -> git@github.com:philippecarphin/utils/../
	#   -> git@github.com:philippecarphin/tests
	#   ex B : relative_url = ../../___
	#   -> git@github.com:philippecarphin/utils/../../
	#   -> git@github.com:
	#   ex C : relative_url = ../../../
	#   -> git@github.com:philippecarphin/utils/../../../
	#   -> git@
	# - Produce completions for the normalized path
	#   ex A : we have a username.  We don't complete projects
	#   ex B : We have a domain and we complete on usernames
	#   ex C : There is no point, the URL isn't relative to anything
	#          so it might as well be a full URL
	# - Make the completions relative again
	#   ex A : Nothing
	#   ex B : compgen -P ../../ -W "$(git config --get-all gitcomp-domain.${domain}.users)" -- ${cur#../../}
	#   ex C : There is no point
	#
}

_gitextra_dir_is_empty(){
	[[ -z $(find "$1" -mindepth 1 -maxdepth 1 -print -quit) ]]
}
_gitextra_single_file_candidate(){
	local rel_to=$1
	if ((${#COMPREPLY[@]} != 1)) ; then
		return
	fi

	if [[ -d ${rel_to}/${COMPREPLY[0]} ]] ; then
		if _gitextra_dir_is_empty ${rel_to}/${COMPREPLY[0]}; then
			COMPREPLY[0]+="/ "
		else
			COMPREPLY[0]+=/
		fi
	elif [[ -f ${rel_to}/${COMPREPLY[0]} ]] ; then
		COMPREPLY[0]+=" "
	fi
}

_git_view(){
	compopt +o default
	compopt +o bashdefault
	# Assumes that COMP_WORDBREAKS contains ':'
	if [[ "${cur}" != *:* ]] ; then
		__git_complete_refs --sfx=:
	else
		__git_complete_revlist_file
	fi
}
