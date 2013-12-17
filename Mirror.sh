#!/bin/bash
# Sync script by johnnychicago and Sprakle

HOST=$1 #this is the phone's IP address
PORT=$2
USER=$3 #for FTPserver on phone
PASSWD=$4
SYNC_DIR=$5 # on the computer
PHONE_DIR=$6 # where the phone keeps its music
LOCKFILE="/var/lock/sync_android"

# first, scan the phone to see if it is there. If not, exit

echo "Checking for device..."
nc -z "$HOST" "$PORT" || exit;
echo "Device found"

# lockfile

if [ ! -e $LOCKFILE ]; then
        trap "rm -f $LOCKFILE; exit" INT TERM EXIT
        touch $LOCKFILE
else
        exit
fi

echo "Lockfile test succeeded, beggining sync"

# access phone by ftp, mirror the phone directory to the sync directory
# and shutdown the phone ftp server

lftp -p "$PORT" -u "$USER","$PASSWD" "$HOST" <<END_SCRIPT
mirror -RL --reverse --delete-first --only-newer --verbose "$SYNC_DIR"  "$PHONE_DIR"
quit
END_SCRIPT

echo "Completed sync"

rm $LOCKFILE
exit 0
