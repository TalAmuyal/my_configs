#!/bin/bash
# shell script to prepend i3status with my stuff

i3status -c ~/.config/i3/i3status.conf | while :
do
	read line
	echo $(python3 ~/.config/i3/my-status.py "$line") || exit 1
done
