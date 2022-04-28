#
# This file was generated by autocomplete-generator https://gitlab.com/philippecaphin/autocomplete-generator
#

# This is the function that will be called when we press TAB.
#
# Its purpose is to examine the current command line (as represented by the
# array COMP_WORDS) and to determine what the autocomplete should reply through
# the array COMPREPLY.
#
# This function is organized with subroutines who  are responsible for setting
# the 'hcron_compreply_candidates' variable.
#
# The compgen then filters out the candidates that don't begin with the word we are
# completing. In this case, if '--' is one of the words, we set empty candidates,
# otherwise, we look at the previous word and delegate # to candidate-setting functions
__complete_hcron() {

	COMPREPLY=()

	# We use the current word to filter out suggestions
	local cur="${COMP_WORDS[COMP_CWORD]}"


	# Compgen: takes the list of candidates and selects those matching ${cur}.
	# Once COMPREPLY is set, the shell does the rest.
	COMPREPLY=( $(compgen -W "$(__suggest_hcron_compreply_candidates 2> ~/.autocomplete_log.txt)" -- ${cur}))

	return 0
}

__suggest_hcron_compreply_candidates(){
	# We use the current word to decide what to do
	local cur="${COMP_WORDS[COMP_CWORD]}"
	if __hcron_dash_dash_in_words ; then
		return
	fi

	option=$(__hcron_get_current_option)
	if [[ "$option" != "" ]] ; then
		__suggest_hcron_args_for_option ${option}
	else
		# Suggest from filesystem if current word doesn't start with '-'
		# if ! [[ "$cur" = -* ]] ; then
		# 	return
		# fi
		__suggest_hcron_options
	fi
}

__hcron_dash_dash_in_words(){
	for ((i=0;i<COMP_CWORD-1;i++)) ; do
		w=${COMP_WORDS[$i]}
		if [[ "$w" == "--" ]] ; then
			return 0
		fi
	done
	return 1
}

__hcron_get_current_option(){
	# The word before that
	local prev="${COMP_WORDS[COMP_CWORD-1]}"
	if [[ "$prev" == -* ]] ; then
		echo "$prev"
	fi
}

__suggest_hcron_options(){
	echo " activate conv doc event get list reload run show-log version"
}

__suggest_hcron_args_for_option(){
	case "$1" in
		activate) __suggest_hcron_key_activate_values ;;
		conv) __suggest_hcron_key_conv_values ;;
		doc) __suggest_hcron_key_doc_values ;;
		event) __suggest_hcron_key_event_values ;;
		get) __suggest_hcron_key_get_values ;;
		list) __suggest_hcron_key_list_values ;;
		reload) __suggest_hcron_key_reload_values ;;
		run) __suggest_hcron_key_run_values ;;
		show-log) __suggest_hcron_key_show_log_values ;;
		version) __suggest_hcron_key_version_values ;;
	esac
}

__suggest_hcron_key_activate_values(){
	echo ""
}

__suggest_hcron_key_conv_values(){
	echo ""
}

__suggest_hcron_key_doc_values(){
	echo ""
}

__suggest_hcron_key_event_values(){
	echo ""
}

__suggest_hcron_key_get_values(){
	echo ""
}

__suggest_hcron_key_list_values(){
	echo ""
}

__suggest_hcron_key_reload_values(){
	echo ""
}

__suggest_hcron_key_run_values(){
	echo ""
}

__suggest_hcron_key_show_log_values(){
	echo ""
}

__suggest_hcron_key_version_values(){
	echo ""
}

complete -o default -F __complete_hcron hcron
