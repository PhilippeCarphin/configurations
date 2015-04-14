# Parsing the options inspired by correction script from INF1995
# This seems to be the standard way of doing it.
while getopts u:p:o:bdnhr opt
do
    case "$opt" in
      u) user=$OPTARG;;
      b) echo "Option b sans argument";;
      \?)		# unknown flag
        echo "Options invalides"
	    ;;
    esac
done
shift `expr $OPTIND - 1`