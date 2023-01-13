################################################################################
# This file shows an example of how to setup custom auto-complete for commands
# of our making.
#
# We start with a function that just prints it's arguments and define another
# function that will be called when we press TAB during the completion of that
# command.
################################################################################

################################################################################
# This is the function that will be called when we press TAB.  It's purpose is
# to examine the current command line (as represented by the array COMP_WORDS)
# and to determine what the autocomplete should reply through the array
# COMPREPLY.  This function is organized with subroutines who are responsible
# for setting the =candidates= variable.   The compgen then filters out the
# candidates that don't begin with the word we are completing.
################################################################################
__ord_soumet_complete()
{
	COMPREPLY=()

	# The word we are trying to complete
	local cur="${COMP_WORDS[COMP_CWORD]}"

	# The word before that
	local prev="${COMP_WORDS[COMP_CWORD-1]}"

    if ! __dash_dash_in_words ; then
        if [[ "$cur" == -* ]] ; then
            __complete_ord_soumet_option
        else
            __complete_ord_soumet_posargs
        fi
    else
        candidates=""
    fi

	# Compgen: takes the list of candidates and selects those matching ${cur}.
	# Once COMPREPLY is set, the shell does the rest.
	COMPREPLY=( $(compgen -W "${candidates}" -- ${cur}))

	return 0
}

__complete_ord_soumet_option(){
    candidates="-addstep -altcfgdir -args -as -c -clone -cm -coschedule -cpus
    -custom -d -display -e -epilog -firststep -geom -image -immediate -iojob -jn
    -jobcfg -jobfile -jobtar -keep -l -laststep -listing -m -mach -mail -mpi
    -node -noendwrap -norerun -norset -nosubmit -notify -o -op -p -postfix -ppid
    -preempt -prefix -prio -project -prolog -q -queue -rerun -resid -rsrc
    -retries -seqno -share -shell -smt -splitstd -sq -ssmuse -step -sys -t -tag
    -threads -tmpfs -v -w -waste -with -wrapdir -xterm"
}

__complete_ord_soumet_posargs(){
    # Make candidates empty, BASH will autocomplete from filesystem
    candidates=""
}

__dash_dash_in_words(){
    for w in ${COMP_WORDS[@]} ; do
        if [[ "$w" == "--" ]] ; then
            return 0
        fi
    done
    return 1
}

################################################################################
# Arrange for the __phil_complete() function to be called when completing the
# command "to_complete".
################################################################################
complete -o default -F __ord_soumet_complete ord_soumet
complete -o default -F __ord_soumet_complete ord_run
