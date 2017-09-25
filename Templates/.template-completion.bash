__template_complete_command()
{
	echo -n "use add"
}

__template_complete_option()
{
	echo -n "--src --dst"
}

__get_available_templates()
{
	ls ~/Templates
}

__template_complete()
{
	COMPREPLY=()

	# echo "COMP_WORDS : ${COMP_WORDS}"


	# The word we are trying to complete
	local cur="${COMP_WORDS[COMP_CWORD]}"

	# The word before that
	local prev="${COMP_WORDS[COMP_CWORD-1]}"

	local candidates=""

	if (( $COMP_CWORD == 1 )) ; then
		candidates=$(__template_complete_command)
	elif [[ "$cur" == -* ]] ; then
		candidates=$(__template_complete_option)
	else
		cmd=${COMP_WORDS[1]}
		if [[ "$cmd" == use ]] && [[ "$prev" == --src ]] ; then
			candidates=$(__get_available_templates $cur)
		elif [[ "$cmd" == add ]] && [[ "$prev" == --dst ]] ; then
			candidates=$(__get_available_templates)
		else
			candidates=$(ls .)
		fi
	fi

	COMPREPLY=( $(compgen -W "$candidates" -- $cur) )


	return 0
}

complete -F __template_complete template
