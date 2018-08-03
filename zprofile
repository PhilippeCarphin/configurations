export CONFIG_DIR=$(cd $(dirname $(readlink ~/.zprofile)) > /dev/null && pwd)

if [ -e /etc/zprofile ] ; then
   source /etc/zprofile
fi

source $CONFIG_DIR/envvars

export PHILRC_ZPROFILE=".zprofile_sourced_at_$(date "+%Y-%m-%d_%H%M")"
