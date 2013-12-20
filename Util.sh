#!/bin/bash

tryNotify()
{
	log "$1" "$2"
	if type "notify-send" > /dev/null; then
		notify-send "Android Wireless Sync" "$1"
	fi
}

arrayContainsElement () {
	
	declare -a array=("${!1}")
	
	for i in "${array[@]}"; do
		if [ "$i" == "$2" ] ; then
			return 0
		fi
	done
	
	return 1
}

log () {
	msg="$1"
	priority=$2
	
	if [ $priority -le $VERBOSITY ]; then
		echo "$msg"
	fi
}
