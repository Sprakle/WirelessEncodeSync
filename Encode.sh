#!/bin/bash
# by Sprakle

source Util.sh

# settings
FROM=$1  # on the computer
TO=$2  # where the phone keeps its music
BITRATE=$3 # bitrate to encode non mp3 files to, max bitrate of mp3 files
WORKERS=$4

doesNeedEncoding ()
{
	source Util.sh

	input=$1
	max=$2
	
	# if not mp3
	type="${input##*.}"
	if [ "$type" != "mp3" ]; then
		log "File needs encoding because it is not an mp3" 3
		return 0
	fi

	bitrate=$(exiftool -AudioBitrate "$input" | grep -o "[0-9]\+")

	# if bitrate cant be read
	if [ -z "$bitrate" ]; then
		log "mp3 file needs encoding because the bitrate cant be read" 3
		return 0
	fi

	# if bitrate is too high
	if [ $bitrate -gt $max ]; then
		log "mp3 file needs encoding because the bitrate is too high" 3
		return 0
	fi

	log "mp3 file does not need encoding" 3
	return 1
}

processFile()
{
	audioFormats=('mp3' 'flac' 'wav') # these files will be encoded or linked if no encoding is needed
	
	source Util.sh
	
	# remove backslashes created by parallel
	fileName=$(sed 's/\\//g' <<< "$1")
	
	from=$2
	to=$3
	bitrate=$4
	
	extension="${fileName##*.}"
	outputFileName=$(convertFilePath "$fileName" "$from" "$to" "mp3")
	
	# For music files
	if arrayContainsElement audioFormats[@] "$extension"; then
		encodeTrack "$fileName" "$outputFileName" "$bitrate"
		return
	fi
}

encodeTrack()
{
	fileName=$1
	outputFileName=$2
	bitrate=$3
	
	log "Encoding track: '$fileName'" 2
	
	# Create directory if it doesn't exist
	mkdir -p "${outputFileName%/*}/"
	
	# if the track file already exists, skip
	if [ -f "$outputFileName" ]; then
		log "File already exists, skipping" 3
		return
	fi
	
	# if not acceptable, encode
	if doesNeedEncoding "$fileName" "$bitrate"; then
		./ffmpeg -nostdin -v panic -i "$fileName" -b:a $bitrate"k" "$outputFileName"
		log "Encoded to: '$outputFileName'" 3
		return
	fi

	log "File will only be linked" 3
	ln -s "$fileName" "$outputFileName"
}

log "Encoding tracks from '$FROM' to '$TO'" 1

# if parallel is installed, use it
if type "parallel" > /dev/null; then
	log "Using parallel to encode music" 1

	export -f processFile
	export -f encodeTrack
	export -f arrayContainsElement
	export -f doesNeedEncoding
	find "$FROM" -type f | parallel --gnu --eta -j"$WORKERS" processFile "{}" "'$FROM'" "'$TO'" "'$BITRATE'"
	
else
	log "NOT using parallel to encode music" 1
	
	find "$FROM" -type f | while read fileName; do
		processFile "$fileName"
	done
fi

tryNotify "Completed encoding or copying of all tracks" 1

exit 0
