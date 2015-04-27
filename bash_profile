# .bash_profile

echo "Sourcing bash_profile"
# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi


