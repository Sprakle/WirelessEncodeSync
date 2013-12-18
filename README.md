WirelessEncodeSync
==================

Wireless encode and sync script intended for android music collections.
**Warning:** This will delete all music on your phone that isn't also on your computer.

## To sync:
1. Download an FTP server android app
	* For me, "FTP Server" by "Rapfox" worked well
	* Make sure you set /sdcard or /mnt/sdcard as the root folder
2. Change settings at the top of Manage.sh (see "Settings" below)
3. Run ./Manage.sh
	* You may need to set the executable permission on the scripts
	* Use a cron job if you want to the the script more than once
4. Refresh your phone's music library (PowerAMP can do this)
	
## Dependencies:
* lftp
* libmp3lame0
* notify-osd (optional, used to notify user at key points)

## Under the hood:
1. Check to see if the user deleted any files from their collection
2. Loop through each file in the user's music collection
	1. Make sure it is a music file
	2. Decide what to do with the file
		* If it is a lossless file, encode it to the set bitrate and copy to the encode directory
		* If it is an mp3 file above the set bitrate, encode it to a lower bitrate and copy to the encode directory
		* If it is an mp3 file equal to or below the set bitrate, create a symbolic link to it in the encode directory
3. Connect to the phone using FTP
4. Synchronize the phone to the encode directory

## Other Information:
* Synchronization is one way only, the music files on your computer will never be affected
* The script is currently set to accept mp3, flac, and wav files, but you may be able to add more by modifying Encode.sh
* No checks are made to make sure the phone's storage capacity is not exceeded
* If you find any problems, email ben.cracknell.96@gmail.com

##Settings
You can change the scripts settings by either changing the Manage.sh file, or passing options when executing it.
Options:
```
-m MUSIC_DIRECTORY
-e ENCODE_DIRECTORY
-b MAX_BITRATE
-h HOST_IP
-p HOST_PORT
-u FTP_USER
-s FTP_PASSWD
-f FTP_DIRECTORY
```
