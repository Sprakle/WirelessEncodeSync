#!/bin/bash
# By johnnychicago and Sprakle

source Util.sh

HOST=$1 #this is the phone's IP address
PORT=$2
USER=$3 #for FTPserver on phone
PASSWD=$4
SYNC_DIR=$5 # on the computer
PHONE_DIR=$6 # where the phone keeps its music
LOCKFILE="/var/lock/sync_android"

# first, scan the phone to see if it is there. If not, exit

log "Checking for device..." 1
if nc -z "$HOST" "$PORT"; then
	log "Device found"
else
	tryNotify "Could not find device" 0
	exit 1
fi

# lockfile

if [ ! -e $LOCKFILE ]; then
	trap "rm -f $LOCKFILE; exit" INT TERM EXIT
	touch $LOCKFILE
else
	tryNotify "Lockfile test failed, device is being synced by someone else" 0
	exit 1
fi

log "Lockfile test succeeded, beggining sync" 1

# access phone by ftp, mirror the phone directory to the sync directory
# and shutdown the phone ftp server

lftp -p "$PORT" -u "$USER","$PASSWD" "$HOST" <<END_SCRIPT
mirror -RL --reverse --delete-first --only-newer --verbose "$SYNC_DIR"  "$PHONE_DIR"
quit
END_SCRIPT

tryNotify "Completed synchronization" 1

rm $LOCKFILE
exit 0
