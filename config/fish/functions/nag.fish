function nag
	set period $argv[1]
set message $argv[2]
set long_message $argv[3]
while true
sleep $period
osx_alert $message $long_message
end
end
