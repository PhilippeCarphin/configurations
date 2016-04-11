echo ".profile called"

# load env domain
. /ssm/net/env/3.1-2/etc/ssm.d/profile

export ORDENV_COMM=ec/20150731
. ordenv-load


if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi
