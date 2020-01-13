# Defined in /tmp/afsmpca/fish.8fqpYb/p.sshpwd.fish @ line 1
function p.sshpwd
	ssh -t $argv "cd $PWD ; bash -l"
end
