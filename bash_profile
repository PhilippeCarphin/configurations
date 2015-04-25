# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

# User specific environment and startup programs
EDITOR=vim
export EDITOR

PATH=$PATH:$HOME/.local/bin:$HOME/bin
export PATH
