if [ -e /etc/zprofile ] ; then
   source /etc/zprofile
fi
source ~/.envvars

export PHILRC_ZPROFILE=".zprofile_sourced_at_$(date "+%Y-%m-%d_%H%M")"

# Setting PATH for Python 3.7
# The original version is saved in .zprofile.pysave
# PATH="/Library/Frameworks/Python.framework/Versions/3.7/bin:${PATH}"
# export PATH

# Setting PATH for Python 3.7
# The original version is saved in .zprofile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.7/bin:${PATH}"
export PATH
