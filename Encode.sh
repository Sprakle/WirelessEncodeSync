#!/bin/bash
# Encode script by Sprakle

source Util.sh

# settings
FROM=$1  # on the computer
TO=$2  # where the phone keeps its music
BITRATE=$3 # bitrate to encode non mp3 files to, max bitrate of mp3 files

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

encode()
{
	source Util.sh
	
	# remove backslashes create by parallel
	trackName=$(sed 's/\\//g' <<< "$1")
	
	# Make sure file is a music file
	extension="${trackName##*.}"
	if ! arrayContainsElement "$extension" ${formatArray}; then
		log "found non music file: $trackName" 3
		return
	fi

	log "Processing track: '$trackName'" 2
	
 	newPath=$trackName
	
	# Replace FROM folder name with TO
	newPath=$(sed "s|$FROM|$TO|g" <<< "$newPath")
	
	# Replace extension with mp3
	newPath="${newPath%.*}.mp3"
	
	# Create directory if it doesn't exist
	mkdir -p "${newPath%/*}/"
	
	# if the track file already exists, skip
	if [ -f "$newPath" ]; then
		log "File already exists, skipping" 3
		return
	fi
	
	# if not acceptable, encode
	if doesNeedEncoding "$trackName" "$BITRATE"; then
		./ffmpeg -nostdin -v panic -i "$trackName" -b:a $BITRATE"k" "$newPath"
		log "Encoded to: '$newPath'" 3
		return
	fi

	log "File will only be linked"  3
	target=$trackName
	link=$newPath
	ln -s "$target" "$link"
}

log "Encoding tracks from '$FROM' to '$TO'" 1

# if parallel is installed, use it
if type "parallel" > /dev/null; then
	log "Using parallel to encode music" 1

	export -f encode
	export -f arrayContainsElement
	export -f doesNeedEncoding
	export FROM
	export TO
	export BITRATE
	find "$FROM" -type f | parallel --gnu --eta -j+0 encode "{}"
	
else
	log "NOT using parallel to encode music" 1
	
	find "$FROM" -type f | while read trackName; do
		encode "$trackName"
	done
fi

tryNotify "Completed encoding or copying of all tracks" 1

exit 0
