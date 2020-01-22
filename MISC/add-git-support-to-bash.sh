#!/bin/bash

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
		wget $file_url

		echo "Moving ./$downloaded_file to ~/$target_file"
		mv $downloaded_file ~/$target_file
	fi

	echo "source ~/$target_file" >> $output_file
}
output_file='./stuff_to_add_to_bashrc'
echo '# Stuff to add to your bashrc' > $output_file

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



echo "
export GIT_PS1_SHOWCOLORHINTS=true
export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export PROMPT_COMMAND='__git_ps1 \"\u@\h:\w\" \" \\\$ \"'
# utiliser \w au lieu de \W pour avoir juste un nom de dossier
" >> $output_file

echo "$(tput setaf 5)See $output_file for things to add to your ~/.bashrc$(tput sgr 0)"
