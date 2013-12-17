#!/bin/bash
# Encode script by Sprakle

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

	bitrate=`exiftool -AudioBitrate "$input" | grep -o "[0-9]\+"`

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

# settings
FROM=$1  # on the computer
TO=$2  # where the phone keeps its music
BITRATE=$3 # bitrate to encode non mp3 files to, max bitrate of mp3 files

echo "Encoding tracks from '$FROM' to '$TO'"

echo "$FROM"
find "$FROM" -name '*.*' | while read trackName; do
	echo -e "\e[1mProcessing track: '$trackName'\e[0m"
	
 	newPath=$trackName
	
	#Replace FROM folder name with TO
	newPath=`sed "s|$FROM|$TO|g" <<< $newPath`
	
	#Replace extension with mp3
	newPath="${newPath%.*}.mp3"

	# if not acceptable, encode
	if doesNeedEncoding "$trackName" "$BITRATE"; then
		./ffmpeg -nostdin -v panic -i "$trackName" -b:a $BITRATE"k" "$newPath"
		echo "Encoded to: '$newPath'"
		sleep 1
		continue
	fi

	echo "File will only be linked"
	target=`realpath .`/$trackName
	link=`realpath .`/$newPath
	ln -s "$target" "$link"

done

echo "Completed encoding or copying of all tracks"

exit 0
