# Option parsing as explained at p.132 of Classic Shell Scripting from O'Reilly
################################################################################

################################################################################
# Function showUsage() displays usage of the script
################################################################################
showUsage()
{
	printf "\033[1;32m
	    Usage: $0 [-A argOptA] [-B] [Arguments]
		Argumenst : Arguments will simply be echoed.
	        -A  Explication de l'option A
	        -B  Explication de l'option B
	        -h  Aide
	 \033[0m\n"
}

################################################################################
# Option Parsing
################################################################################

# Option arguments and flags to be set
optionA_arg=
optionB=

# Basic option parsing loop with getopts (can only handle single letter options 
# but still does it POSIX style so one dash and multiple letters works.)
while getopts :A:Bh opt # A is followed by ":" to say that it requires an argument. Leading ":" to let me handle invalid options instead of having an automatic error message.
do
	case $opt in
		A) 	optionA_arg=$OPTARG
			;;
		B) 	optionB=true
			;;
		h)	showUsage
			exit 1
			;;
		?)	printf "\033[1;31mInvalid options \033[0m\n"
			showUsage
			exit 1
			;;
	esac
done
shift $((OPTIND - 1)) # Remove options and leave arguments


################################################################################
# Argument parsing/treatment
################################################################################
for arg in "$@"
do
	echo "$arg"
done
