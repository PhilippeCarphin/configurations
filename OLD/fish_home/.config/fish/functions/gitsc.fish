# Defined in /var/folders/0k/d6bmjgqx4hl0tjpr7ss8nxk80000gn/T//fish.m6Mgbo/gitsc.fish @ line 2
function gitsc
	env ALL_PROXY=socks5h://127.0.0.1:8080 GIT_SSL_NO_VERIFY=1 git $argv
end
