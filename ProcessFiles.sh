#!/bin/bash
# by Sprakle

source Util.sh

# settings
FROM=$1  # on the computer
TO=$2  # where the phone keeps its music
BITRATE=$3 # bitrate to encode non mp3 files to, max bitrate of mp3 files
WORKERS=$4

log "Encoding tracks from '$FROM' to '$TO'" 1

# if parallel is installed, use it
if type "parallel" > /dev/null; then
	log "Using parallel to encode music" 1

	find "$FROM" -type f | parallel --gnu --eta -j"$WORKERS" ./ProcessFile.sh "{}" "'$FROM'" "'$TO'" "'$BITRATE'"
	
else
	log "NOT using parallel to encode music" 1
	
	find "$FROM" -type f | while read fileName; do
		./ProcessFile.sh "$fileName"
	done
fi

tryNotify "Completed encoding or copying of all tracks" 1

exit 0
