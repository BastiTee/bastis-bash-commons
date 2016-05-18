#!/bin/bash
# ==============================================================================
# EXIF TO FILENAME (BASTI's BASH COMMONS)
# Renames JPG files to file pattern IMG_TIMESTAMP_BASENAME, e.g.,
# from 1234.JPG to IMG_20150212_1220_1234.jpg 
#
# Licensed under the Apache License, Version 2.0 (the "License");
# ==============================================================================

[ -z "$1" ] && { echo "No input folder"; exit 1; } || ifolder="$1"
[ "$2" == "0" ] && sim=0 || sim=1

ifolder=$( readlink -f "$1" )

echo "-- input = $ifolder"
echo "-- sim   = $sim"

find "$ifolder" -type f -iname "*.jpg" -o -iname "*.jpeg" | while read file
do
	base=$( basename "$file" | sed -r -e "s/IMG_//Ig" -e "s/\.[^\.]+$//g" )
	[ $sim == 1 ] && echo "base = $base"
	tstamp=$( exif -mt 0x0132 "$file" | tr " " "_" | tr -d ":" )
	dirn=$( dirname "$file" )
	newfile="${dirn}/IMG_${tstamp}_${base}.jpg"
	command="mv -v \"$file\" \"$newfile\""
	[ $sim == 1 ] && echo "$command" || eval "$command" 
done