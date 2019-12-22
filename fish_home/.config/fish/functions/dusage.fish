# Defined in /var/folders/0k/d6bmjgqx4hl0tjpr7ss8nxk80000gn/T//fish.jRiAtM/dusage.fish @ line 2
if [ (uname) = Darwin ]
    function dusage
        du -d 1 -h | sort -h
    end
else
    function dusage
        du --max-depth=1 -h | sort -h
    end
end
