function osx_alert
	osascript -e 'display alert "'$argv[1]'" message "'$argv[2]'"'
end
