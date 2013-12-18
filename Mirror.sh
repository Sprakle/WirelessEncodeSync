#!/bin/bash
# Sync script by johnnychicago and Sprakle

HOST=$1 #this is the phone's IP address
PORT=$2
USER=$3 #for FTPserver on phone
PASSWD=$4
SYNC_DIR=$5 # on the computer
PHONE_DIR=$6 # where the phone keeps its music
LOCKFILE="/var/lock/sync_android"

tryNotify()
{
	echo "$1"
	if type "notify-send" > /dev/null; then
		notify-send "Android Wireless Sync" "$1"
	fi
}

# first, scan the phone to see if it is there. If not, exit

echo "Checking for device..."
if nc -z "$HOST" "$PORT"; then
	echo "Device found"
else
	tryNotify "Could not find device"
	exit 1
fi

# lockfile

if [ ! -e $LOCKFILE ]; then
	trap "rm -f $LOCKFILE; exit" INT TERM EXIT
	touch $LOCKFILE
else
	tryNotify "Lockfile test failed, device is being synced by someone else"
	exit 1
fi

echo "Lockfile test succeeded, beggining sync"

# access phone by ftp, mirror the phone directory to the sync directory
# and shutdown the phone ftp server

lftp -p "$PORT" -u "$USER","$PASSWD" "$HOST" <<END_SCRIPT
mirror -RL --reverse --delete-first --only-newer --verbose "$SYNC_DIR"  "$PHONE_DIR"
quit
END_SCRIPT

tryNotify "Completed synchronization"

rm $LOCKFILE
exit 0
