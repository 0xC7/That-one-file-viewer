#!/bin/bash
# Thank you Dan for the lovely code model from Minecraft Control.
# https://github.com/DanH42/mc-control
# Todo: Add tailing abilities (will need to make ruby server output to log file)

start(){
	if [ "$(status)" = "Running" ]; then
		echo "[Error] Ruby file viewer already running!"
	else
		screen -dmS sharex_server ruby sharex_server.rb
		echo "Ruby file viewer started."
	fi
}
stop(){
	if [ "$(status)" = "Running" ]; then
		screen -X -S sharex_server quit
		echo "Ruby file viewer stopped."
	else
		echo "[Error] Ruby file viewer not running!"
	fi
}
restart(){
	if [ "$(status)" = "Running" ]; then
		echo $(stop)
	fi
	echo $(start)
}
status(){
	if screen -list | grep -q "sharex_server"; then
		echo "Running"
	else
		echo "Not Running"
	fi
}
case "$1" in
	start)
		echo $(start)
		;;
	stop)
		echo $(stop)
		;;
	restart)
		echo $(restart)
		;;
	join)
		if [ "$(status)" = "Running" ]; then
			screen -dr sharex_server
		else
			echo "[Error] Ruby file viewer not running!"
		fi
		;;
	status)
		echo $(status)
		;;
	*)
		echo "Status:" $(status)
		echo "Options:"
		echo "	sharex_server start | stop | restart"
		echo "	sharex_server join"
		;;
esac
