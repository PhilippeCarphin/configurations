#!/bin/bash

# Message from Phil, for people that are new to git and bash, this may seem
# confusing to you, but I encourage you to look at the commands and try to
# understand what is happening.

# The weirdest thing is the [ -e ... -o -L ] and what that does is that in [ ],
# it is a test and it reads like this :
# " -e (is a file) file -o (or) -L (is a link) file"
# so basically, this checks if the file exists whether it's a regular file or a
# link.

# The rest of the commands are self documented by an echo statement right before
# it.  You should look up what the >> operator does. HINT: google 'bash io
# redirection'

# The last tricky thing is the use of grep. The grep command takes a string as
# first argument and then a list of files.  It outputs the lines that contain
# the string.  And $(cmd) "captures" the output of grep.  The test says "If the
# output of the grep command is empty".  The grep command is super useful to
# search through code and other files because it also supports regular
# expressions.

# Also note that function arguments don't show up in the declaration.  That's
# they are all strings and bash is very loose.  But functions can take arguments
# and when they do, we access them in the function using $1, $2, ...

# To make code more readable, I always assign these arguments to variables with
# better names.  This makes the code of the function more readable and also
# documents the functions interface (i.e. what arguments it expects).

################################################################################
# If the file exists, nothing is done, otherwise, wget is used to download the
# file, then move the file to the home folder under the target name.
################################################################################
get_and_source(){

	local file_url=$1
	local target_file=$2
	local downloaded_file=$(basename $file_url)

	echo "$(tput setaf 2)Setting up $downloaded_file$(tput sgr 0)"

	# Abort if the file already exists
	if [ -e ~/$target_file -o -L ~/$target_file ]; then
		echo "$target_file already present in home, not downloading"
	else
		echo "Downloading $downloaded_file from $file_url"
		wget $file_url 1>/dev/null 2>&1

		echo "Moving ./$downloaded_file to ~/$target_file"
		mv $downloaded_file ~/$target_file
	fi

	echo "source ~/$target_file" >> $output_file
}
output_file='./stuff_to_add_to_bashrc'

# git-prompt.sh will allow us to display the current branch in the prompt string
# by using the function __git_ps1
git_prompt_url=https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
git_prompt_file=.git-prompt.sh
get_and_source $git_prompt_url $git_prompt_file


# git-completion.bash will allow us to have autocompletion of git commands and
# branch names by pressing tab.
git_completion_url=https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
git_completion_file=.git-completion.bash
get_and_source $git_completion_url $git_completion_file

# This next part appends the content of the variable phil_colors to the bashrc
# with a check that it has not already been done.
phil_colors="
# Define colors for making prompt string.
# Phil_PS1
# Vous pouvez changer les couleurs en changeant les nombres
green='\[\$(tput setaf 2)\]'
yellow='\[\$(tput setaf 3)\]'
purple='\[\$(tput setaf 5)\]'
blue='\[\$(tput setaf 4)\]'
no_color='\[\$(tput sgr 0)\]'
PS1=\$green'[\u@\h \W'\$yellow'\$(__git_ps1 \" (%s)\")'\$green'] \\$ '\$no_color"

echo "$(tput setaf 2)Setting up prompt string$(tput sgr 0)"
if ! grep Phil_PS1 ~/.bashrc >/dev/null 2>&1 ; then
	echo "Adding Phil_colors to $output_file"
	echo "$phil_colors" >> $output_file
else
	echo "prompt string already setup"
fi

echo "$(tput setaf 5)See $output_file for things to add to your ~/.bashrc$(tput sgr 0)
"
