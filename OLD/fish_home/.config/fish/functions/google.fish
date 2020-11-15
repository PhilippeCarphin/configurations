# Defined in /var/folders/0k/d6bmjgqx4hl0tjpr7ss8nxk80000gn/T//fish.lZzXof/google.fish @ line 2
function google
	set -l query ""

   for arg in $argv[1..-1]
       set query "$query+$arg"
   end
	if [ (uname) = Darwin ]
       open "https://google.com/search?q=$query"
   else
       xdg-open https://google.com
   end
end
