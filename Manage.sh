#!/bin/bash
# Encode and Sync script by Sprakle

MUSIC_DIRECTORY=$1 # on the computer
ENCODE_DIRECTORY=$2 # where to store encoded music
MAX_BITRATE=$3 # max bitrate per track

HOST_IP=$4
HOST_PORT=$5
FTP_USER=$6
FTP_PASSWD=$7
FTP_DIRECTORY=$8 # where the phone keeps its music

#Encode required files
./Encode.sh "$MUSIC_DIRECTORY" "$ENCODE_DIRECTORY" $MAX_BITRATE

#Sync it all
./Mirror.sh $HOST_IP $HOST_PORT "$FTP_USER" "$FTP_PASSWD" "$ENCODE_DIRECTORY" "$FTP_DIRECTORY"

exit 0
