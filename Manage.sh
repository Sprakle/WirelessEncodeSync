#!/bin/bash
# Encode and Sync script by Sprakle

MUSIC_DIRECTORY="$HOME/Nexus Sync/Music" # on the computer
ENCODE_DIRECTORY="$HOME/Nexus Sync/Encoded" # where to store encoded music
MAX_BITRATE=256 # max bitrate per track

HOST_IP=192.168.0.21
HOST_PORT=2121
FTP_USER=sprakle
FTP_PASSWD=nexusFTPswag
FTP_DIRECTORY=Music # where the phone keeps its music

# setting overrides
while getopts "m:e:b:h:p:u:s:f:" opt; do
	case $opt in
		m)	MUSIC_DIRECTORY=$OPTARG;;
		e)	ENCODE_DIRECTORY=$OPTARG;;
		b)	MAX_BITRATE=$OPTARG;;
		h)	HOST_IP=$OPTARG;;
		p)	HOST_PORT=$OPTARG;;
		u)	FTP_USER=$OPTARG;;
		s)	FTP_PASSWD=$OPTARG;;
		f)	FTP_DIRECTORY=$OPTARG;;
	esac
done

# check for files that have been deleted from the music folder
echo "Checking for files deleted from the music directory"
find "$ENCODE_DIRECTORY" -name '*.*' -type f | while read trackName; do
	
	newPath=$trackName

	# Replace ENCODE directory name with MUSIC directory name
	newPath=$(sed "s|$ENCODE_DIRECTORY|$MUSIC_DIRECTORY|g" <<< "$newPath")
	
	# Remove extension
	newPath="${newPath%.*}"
	
	# Check
	if [ ! -e "$newPath".* ]; then
		echo "Deleted file found: $newPath"
		rm "$trackName"
		continue
	fi
done
echo "Done checking"

#Encode required files
./Encode.sh "$MUSIC_DIRECTORY" "$ENCODE_DIRECTORY" $MAX_BITRATE

#Sync it all
./Mirror.sh $HOST_IP $HOST_PORT "$FTP_USER" "$FTP_PASSWD" "$ENCODE_DIRECTORY" "$FTP_DIRECTORY"

exit 0
