#!/bin/bash
# Thank you Dan for the lovely code model from Minecraft Control.
# https://github.com/DanH42/mc-control
# Todo: Add tailing abilities (will need to make ruby server output to log file)

# default path = /usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
export sharex_root="${0%/*}"
SHAREX_SESSION_NAME="sharex_server.${USER}"
start(){
	if [ "$(status)" = "Running" ]; then
		echo "[Error] Ruby file viewer already running!"
	else
		screen -dmS "${SHAREX_SESSION_NAME}" bash
		if [ ! $(command -v ruby >/dev/null 2>&1) ] ; then
			# Try local RVM installation
			screen -S "${SHAREX_SESSION_NAME}" -X stuff '[[ -s "${HOME}/.rvm/scripts/rvm" ]] && . "${HOME}/.rvm/scripts/rvm"'$(echo -ne '\015')
		fi
		# attempt #2
		if [ $(command -v ruby >/dev/null 2>&1) ]; then
			echo "[Error] Unable to find ruby executable. Server \e[1;31mNOT\e[0m started."
		else
			screen -S "${SHAREX_SESSION_NAME}" -X stuff 'cd ${sharex_root}'$(echo -ne '\015')
			screen -S "${SHAREX_SESSION_NAME}" -X stuff 'ruby sharex_server.rb'$(echo -ne '\015')
			echo "Ruby file viewer started."
		fi
	fi
}
stop(){
	if [ "$(status)" = "Running" ]; then
		screen -X -S "${SHAREX_SESSION_NAME}" quit
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
	if screen -list | grep -q "${SHAREX_SESSION_NAME}"; then
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
			screen -dr "${SHAREX_SESSION_NAME}"
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
		echo "  sharex_server start | stop | restart"
		echo "  sharex_server join"
		;;
esac
