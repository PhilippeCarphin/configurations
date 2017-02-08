# .bash_profile

echo "Sourcing bash_profile"
# Get the aliases and functions
if [ -f ~/.profile ]; then
	. ~/.profile
fi

if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

PATH=$PATH:$HOME/.local/bin


# Setting PATH for Python 3.5
# The orginal version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.5/bin:${PATH}"
export PATH

# added by Anaconda3 4.3.0 installer
# It broke youCompleteMe in vim so I'm commenting it out for now.
# export PATH="/Users/pcarphin/anaconda/bin:$PATH"
