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

#Encode required files
./Encode.sh "$MUSIC_DIRECTORY" "$ENCODE_DIRECTORY" $MAX_BITRATE

#Sync it all
./Mirror.sh $HOST_IP $HOST_PORT "$FTP_USER" "$FTP_PASSWD" "$ENCODE_DIRECTORY" "$FTP_DIRECTORY"

exit 0
