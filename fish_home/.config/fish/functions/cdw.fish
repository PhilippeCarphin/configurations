# Defined in /var/folders/0k/d6bmjgqx4hl0tjpr7ss8nxk80000gn/T//fish.HKvHWH/cdw.fish @ line 2
function cdw
	set -l program $argv[1]
   set -l dir (dirname (which $program))
   cd $dir
end
