#!/bin/bash

my_option_arg=default_value
my_flag=false
while [[ $# -gt 0 ]]
do
    option="$1"
	optarg="$2"
    case $option in
        -o|--my_option)
			my_option_arg="$optarg"
			shift
			;;
		-f|--my_flag)
			my_flag=true
			;;
        *)
            echo "unknown option: $option"
            exit
			;;
    esac
shift
done

