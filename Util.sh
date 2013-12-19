tryNotify()
{
	log "$1" "$2"
	if type "notify-send" > /dev/null; then
		notify-send "Android Wireless Sync" "$1"
	fi
}

arrayContainsElement () {
	audioFormats=('mp3' 'flac' 'wav')
	
	for i in "${audioFormats[@]}"; do
		if [ "$i" == "$1" ] ; then
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
