#!/bin/bash
# Encode and Sync script by Sprakle

source Util.sh

MUSIC_DIRECTORY="$HOME/Nexus Sync/Music" # on the computer
ENCODE_DIRECTORY="$HOME/Nexus Sync/Encoded" # where to store encoded music
MAX_BITRATE=256 # max bitrate per track
ENCODE_WORKERS=+0 # '+0' means {number of cores} plus 0

HOST_IP=192.168.0.21
HOST_PORT=2121
FTP_USER=sprakle
FTP_PASSWD=nexusFTPswag
FTP_DIRECTORY=Music # where the phone keeps its music

VERBOSITY=1 # 0 is minimal verbosity, 3 is maximum

# setting overrides
while getopts "m:e:b:w:h:p:u:s:f:v:" opt; do
	case $opt in
		m)	MUSIC_DIRECTORY=$OPTARG;;
		e)	ENCODE_DIRECTORY=$OPTARG;;
		b)	MAX_BITRATE=$OPTARG;;
		w)	ENCODE_WORKERS=$OPTARG;;
		h)	HOST_IP=$OPTARG;;
		p)	HOST_PORT=$OPTARG;;
		u)	FTP_USER=$OPTARG;;
		s)	FTP_PASSWD=$OPTARG;;
		f)	FTP_DIRECTORY=$OPTARG;;
		v)	VERBOSITY=$OPTARG;;
	esac
done

export VERBOSITY

# check for files that have been deleted from the music folder
log "Checking for files deleted from the music directory" 1
find "$ENCODE_DIRECTORY" -name '*.*' -type f | while read trackName; do
	
	newPath=$trackName

	# Replace ENCODE directory name with MUSIC directory name
	newPath=$(sed "s|$ENCODE_DIRECTORY|$MUSIC_DIRECTORY|g" <<< "$newPath")
	
	# Remove extension
	newPath="${newPath%.*}"
	
	# Check
	if [ ! -e "$newPath".* ]; then
		log "Deleted file found: $newPath" 2
		rm "$trackName"
		continue
	fi
done
log "Done checking" 1

#Encode required files
./Encode.sh "$MUSIC_DIRECTORY" "$ENCODE_DIRECTORY" $MAX_BITRATE "$ENCODE_WORKERS"

#Sync it all
./Mirror.sh $HOST_IP $HOST_PORT "$FTP_USER" "$FTP_PASSWD" "$ENCODE_DIRECTORY" "$FTP_DIRECTORY"

exit 0
