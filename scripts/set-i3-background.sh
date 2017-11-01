#!/bin/bash

wallpapers_path=/home/tala/Documents/MyConfigurations/wallpapers
random_wallpaper=$(ls "$wallpapers_path" | sort -R | tail --lines=1)
feh --bg-scale "$wallpapers_path""/""$random_wallpaper"
