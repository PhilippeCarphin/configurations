# Defined in - @ line 2
function osx_notify
	set osx_notif_message $argv[1]
    set osx_notif_title $argv[2]
    set osascript_notif_command "display notification \""$osx_notif_message"\" with title \""$osx_notif_title\"
    osascript -e $osascript_notif_command
end
