#!/bin/bash
# by Sprakle

audioFormats=('mp3' 'flac' 'wav') # these files will be encoded or linked if no encoding is needed
justLinkFormats=('m3u' 'pls' 'xspf') # these files will just be linked

source Util.sh

encodeTrack()
{
	fileName=$1
	outputFileName=$2
	bitrate=$3
	
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

	log "File does not need encoding, so it will only be linked" 3
	ln -s "$fileName" "$outputFileName"
}

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

# remove backslashes created by parallel
fileName=$(sed 's/\\//g' <<< "$1")

log "Processing file: '$fileName'" 2

from=$2
to=$3
bitrate=$4

extension="${fileName##*.}"

# For music files
if arrayContainsElement audioFormats[@] "$extension"; then
	log "File is in 'audioFormats' array, will only be encoded if needed" 3
	
	outputFileName=$(convertFilePath "$fileName" "$from" "$to" "mp3")
	encodeTrack "$fileName" "$outputFileName" "$bitrate"
	exit
fi

# For files that only need to be linked
if arrayContainsElement justLinkFormats[@] "$extension"; then
	log "File is in 'justLinkFormats' array, will only be linked" 3
	
	outputFileName=$(convertFilePath "$fileName" "$from" "$to" "$extension")
	ln -s "$fileName" "$outputFileName"
	exit
fi
