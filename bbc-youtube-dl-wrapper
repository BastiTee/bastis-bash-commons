#!/bin/bash
# ==============================================================================
# YOUTUBE-DL WRAPPER (BASTI's BASH COMMONS)
# A wrapper to simplify downloading YouTube playlists to MP3.
# https://github.com/rg3/youtube-dl/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# ==============================================================================


YOUTUBE_BIN="youtube-dl"
FFMPEG_BIN="ffmpeg"
[ -v "$( command -v $YOUTUBE_BIN )" ] && { echo "No $YOUTUBE_BIN present."; exit 1; }
[ -v "$( command -v $FFMPEG_BIN )" ] && { echo "No $FFMPEG_BIN present."; exit 1; }
DEBUG=0
PLAYLIST_FOLDER="YOUTUBE"
REFERENCE_FILE="${PLAYLIST_FOLDER}.txt"

read -p "Enter youtube username: " USERNAME
read -s -p "Enter youtube password: " PASSWORD
echo ""
read -p "Enter playlist id: " PLAYLIST

clear

function fix_names() {
    basename "$@" | sed -r \
    `# Strip leading and trailing whitespaces` \
    -e "s/^[[:space:]]*//g" -e "s/[[:space:]]*$//g" \
    `# Remove file suffix` \
    -e "s/\\.[^\\.]+$//g" \
    `# Normalize some characters` \
    -e "s/[–_]/-/g" \
    `# Remove youtube id` \
    -e "s/-[[:alnum:][:graph:]]{10,}[[:space:]]*$//g" \
    `# Remove square brackets text` \
    -e "s/\[[^]]+\]//g" \
    `# 'break' paranthesis of feature infos` \
    -e "s/\(((feat\.)|(ft\.))/feat./Ig" \
    `# 'break' paranthesis of production infos` \
    -e "s/\(((prod\.)|(prod\. von)|(prod\. by)|(prod\. by -)|(prod\. -))/prod./Ig" \
    `# normalize prod. and feat. infos` \
    -e "s/[-[:space:]]+prod\./ prod./g" -e "s/prod\. by/prod./g" -e "s/ft./feat./g" \
    `# remove remaining paranthesis` \
    -e "s/[[:space:]]*\([^\)]*\)//g" -e "s/[\(\)]//g" \
    `# remove hashtags` \
    -e "s/#[^[:space:]]+//g" \
    `# remove some recurring strings` \
    -e "s/RMX/Remix/g" -e "s/[ ]*-?[ ]*juice premiere//Ig" -e "s/ - Official.*//Ig" \
    `# Strip leading and trailing whitespaces and minus` \
    -e "s/^[[:space:]\-]*//g" -e "s/[[:space:]\-]*$//g" \
    `# put featuring at end` \
    -e "s/ - / ~ /g" -e "s/(.*)(feat\. [^~]+)(.*)/\1\3 (\2)/Ig" -e "s/~/-/g" \
    `# put prod at end` \
    -e "s/ - / ~ /g" -e "s/(.*)(prod\. [^~(]+)(.*)/\1\3 (\2)/Ig" -e "s/~/-/g" \
    `# replace double paranthesis in prod/feat files with comma` \
    -e "s/[[:space:]]*\)[[:space:]]+\([[:space:]]*/, /g" \
    `# replace all uppercase words with first letter uppercase` \
    -e "s/([A-Z])([A-Z]{2,})/\1\L\2/g" \
    `# cleanup - remove multiple whitespaces and whitespaces before parant.` \
    -e "s/[[:space:]]+/ /g" -e "s/\( /(/g" -e "s/ \)/)/g" \
    `# cleanup - catch double paranthesis` \
    -e "s/(, \(prod)/, prod/g" -e "s/\)\)/)/g"
}

function do_prename() {
    echo "---- PRENAMING" 
    find "${PLAYLIST_FOLDER}/MP3" -maxdepth 1 -type f | while read file; do
        new_file="${PLAYLIST_FOLDER}/MP3/$( fix_names "$file" ).mp3"
        if [ "$file" != "$new_file" ]; then
			echo "-- FIXING = $file"
            [ $DEBUG == 1 ] && echo "'$new_file'" || mv -v "$file" "$new_file"
        else
			echo "-- FIXING = (DONE_BEFORE) $file"
		fi
    done
    [ $DEBUG == 1 ] && exit 1
}

function do_download() {
    echo "---- DOWNLOADING" 
    $YOUTUBE_BIN \
    --username $USERNAME \
    --password $PASSWORD \
    --output ${PLAYLIST_FOLDER}'/%(title)s-%(id)s.%(ext)s' \
    --playlist-reverse \
    --ffmpeg-location . \
    https://www.youtube.com/playlist?list=${PLAYLIST}
}
 
function do_convert() {
    echo "---- CONVERTING" 
    mkdir -p ${PLAYLIST_FOLDER}/MP3
    find "$PLAYLIST_FOLDER" -maxdepth 1 -type f | while read file; do
        tfile="${PLAYLIST_FOLDER}/MP3/$( fix_names "$file" ).mp3"
        size=$( wc -c "$file" | cut -d' ' -f1)
        if [ $size -ge 50 ]; then
            echo "-- FROM = $file"
            echo "-- TO   = $tfile"
            $FFMPEG_BIN -i "$file" -ac 2 -ab 256k "$tfile" </dev/null
            echo "-downloaded-" > "$file"
        else
            echo "-- FROM = (DONE_BEFORE) $file"
		fi
    done
}

do_prename
do_download
do_convert
