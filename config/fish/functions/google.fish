# Defined in /var/folders/0k/d6bmjgqx4hl0tjpr7ss8nxk80000gn/T//fish.lGDhZ6/google.fish @ line 2
function google
	set -l query $argv[1]

   for arg in $argv[2..-1]
       set query "$query+$arg"
   end
	if [ (uname) = Darwin ]
       open "https://google.com/search?q=$query"
   else
       xdg-open https://google.com
   end
end
