# .bash_profile
################################################################################
# Pulls the configurations
################################################################################
pull_config(){
	pushd $CONFIG_DIR
	git pull
	popd
}

export CONFIG_DIR=$(dirname $(readlink ~/.bashrc))
pull_config


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

# Locally installed programs
export PATH=$PATH:$HOME/.local/bin
# Utility scripts that I keep track of with git.
export PATH=$HOME/Documents/GitHub/utils:$PATH

# Add cuda stuff to path
#export PATH=/usr/local/cuda/bin:$PATH
export PATH=/Developer/NVIDIA/CUDA-8.0/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib"
export THEANO_FLAGS=device=gpu,force_device=True,optimizer=fast_run
export DYLD_LIBRARY_PATH=/Developer/NVIDIA/CUDA-8.0/lib\
	${DYLD_LIBRARY_PATH:+:${DYLD_LIBRARY_PATH}}

# Setting PATH for Python 3.5
# The orginal version is saved in .bash_profile.pysave
export PATH="/Library/Frameworks/Python.framework/Versions/3.5/bin:${PATH}"
export PATH

# added by Anaconda3 4.3.0 installer
# It broke youCompleteMe in vim so I'm commenting it out for now.
# export PATH="/Users/pcarphin/anaconda/bin:$PATH"
