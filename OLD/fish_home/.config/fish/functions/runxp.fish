# Defined in /var/folders/0k/d6bmjgqx4hl0tjpr7ss8nxk80000gn/T//fish.CG4LbV/runxp.fish @ line 2
function runxp
	echo (tput setab 11)"Put TWO \"%\" after \"the\" password"(tput sgr 0)
    if [ (uname) = Darwin ]
        xfreerdp /d:ecquebec /u:Carphinp /size:1400x1050 /network:broadband /proxy:socks5://localhost:8080 /sec:tls /v:eccmcwts6.cmc.int.ec.gc.ca
    else
        nohup rdesktop -g 1900x1000 eccmcwts5 -d ECQUEBEC -u CarphinP > /dev/null &
    end
end
