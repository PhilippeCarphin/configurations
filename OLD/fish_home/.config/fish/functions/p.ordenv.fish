# Defined in /tmp/fish.oxIkRi/p.ordenv.fish @ line 1
function p.ordenv
	. /ssm/net/env/3.1/etc/ssm.d/profile
    export ORDENV_COMM=ec/20141112
    . ordenv-load
end
