# Defined in /var/folders/0k/d6bmjgqx4hl0tjpr7ss8nxk80000gn/T//fish.DExOLY/p.git-push-all.fish @ line 2
function p.git-push-all
	if ! set -q argv[1] ;
        echo "$argv[0] : ERROR : Specifying a remote is mandatory" >&2
        return 1
    end

	set remote $argv[1]

	for b in (git branch --format='%(refname:short)') ;
        echo (tput setaf 2)"$cmd"(tput sgr 0)
        if ! git push $remote $b ;
            return $status
        end
    end
end
