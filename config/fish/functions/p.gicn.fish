function p.gicn
	ssh -Y -t ppp$argv[1] 'ssh -Y $(cat ~/node_info/node_host_'$argv[1]'.txt)'
end
