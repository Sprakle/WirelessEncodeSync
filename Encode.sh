#!/bin/bash
# Encode script by Sprakle

audioFormats=('mp3' 'flac' 'wav')

# settings
FROM=$1  # on the computer
TO=$2  # where the phone keeps its music
BITRATE=$3 # bitrate to encode non mp3 files to, max bitrate of mp3 files

doesNeedEncoding ()
{
	input=$1
	max=$2
	
	# if not mp3
	type="${input##*.}"
	if [ "$type" != "mp3" ]; then
		echo "File needs encoding because it is not an mp3"
		return 0
	fi

	bitrate=$(exiftool -AudioBitrate "$input" | grep -o "[0-9]\+")

	# if bitrate cant be read
	if [ -z "$bitrate" ]; then
		echo "mp3 file needs encoding because the bitrate cant be read"
		return 0
	fi

	# if bitrate is too high
	if [ $bitrate -gt $max ]; then
		echo "mp3 file needs encoding because the bitrate is too high"
		return 0
	fi

	echo "mp3 file does not need encoding"
	return 1
}

encode()
{
	trackName=$1
	
	# Make sure file is a music file
	extension="${trackName##*.}"
	if [[ ! ${audioFormats[*]} =~ "$extension" ]]; then
		echo "found non music file: $trackName"
		continue
	fi

	echo -e "\e[1mProcessing track: '$trackName'\e[0m"
	
 	newPath=$trackName
	
	# Replace FROM folder name with TO
	newPath=$(sed "s|$FROM|$TO|g" <<< "$newPath")
	
	# Replace extension with mp3
	newPath="${newPath%.*}.mp3"
	
	# Create directory if it doesn't exist
	mkdir -p "${newPath%/*}/"
	
	# if the track file already exists, skip
	if [ -f "$newPath" ]; then
		echo "File already exists, skipping"
		continue
	fi
	
	# if not acceptable, encode
	if doesNeedEncoding "$trackName" "$BITRATE"; then
		./ffmpeg -nostdin -v panic -i "$trackName" -b:a $BITRATE"k" "$newPath"
		echo "Encoded to: '$newPath'"
		continue
	fi

	echo "File will only be linked"
	target=$trackName
	link=$newPath
	ln -s "$target" "$link"
}

echo "Encoding tracks from '$FROM' to '$TO'"

find "$FROM" -type f | while read trackName; do
	encode "$trackName"
done

echo "Completed encoding or copying of all tracks"

exit 0
