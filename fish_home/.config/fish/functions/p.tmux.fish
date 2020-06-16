# Defined in /tmp/fish.6ZLZtu/p.tmux.fish @ line 2
function p.tmux
	if ! tmux -S /tmp/pair attach
        tmux -S /tmp/pair
    end
end
