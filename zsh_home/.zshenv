# echo "SOURCING ~/.zshenv" >&2
export PHILRC_ZSHENV=".zshenv_sourced_at_$(date "+%Y-%m-%d_%H%M")"
# echo "... ~/.zshenv sourcing PHILCONFIG/FILES/envvars" >&2
source $HOME/.philconfig/FILES/envvars
