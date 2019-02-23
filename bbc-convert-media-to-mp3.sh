#!/bin/bash
: '
CONVERT MEDIA TO MP3 (BASTIS BASH COMMONS)

Reads the content of the given input file and converts files to mp3s
using ffmpeg. Example:

bbc-convert-media-to-mp3.sh -i in_dir/ -t out_dir/ -p mp3,opus,aac -rsv

Licensed under the Apache License, Version 2.0 (the "License");
'

function show_help () {
    [ ! -z "$1" ] && echo "$1"
    cat << EOF

Usage: $( basename $0 ) -i SOURCE_FOLDER -t TEMP_FOLDER [-r] [-p PATTERN] [-s] [-v]

  -i SOURCE_FOLDER   Source folder containing unconverted media files.
  -t TEMP_FOLDER     Temporary folder for media conversion.
  -r                 Replace whitespaces in files and convert to lower-case.
  -p PATTERN         File suffixes to search for files. Default: mp3
  -s                 Synchronize result folder into source folder after process.
  -v                 Verbose output.

EOF
    exit 1
}

while getopts "i:t:rsvp:h" opt; do
    case "$opt" in
        i) SRC_DIR=$OPTARG ;;
        t) TEMP_DIR=$OPTARG ;;
        r) REPLACE_WHITESPACE=1 ;;
        p) MATCH_SUFFIX=$OPTARG ;;
        v) VERBOSE=1 ;;
        s) SYNC=1 ;;
        h) show_help ;;
        *) show_help "Illegal argument." ;;
    esac
done

MATCH_SUFFIX=${MATCH_SUFFIX:-mp3}
REPLACE_WHITESPACE=${REPLACE_WHITESPACE:-0}
VERBOSE=${VERBOSE:-0}
SYNC=${SYNC:-0}
[ $SYNC == 1 ] && [ -z "$( command -v rsync )" ] && show_help "Synchronization option selected but 'rsync' not on system path."
[ -z "$( command -v ffmpeg )" ] && show_help "'ffmpeg' not on system path."
[ -z "$SRC_DIR" ] && show_help "Source folder not set."
[ -z "$TEMP_DIR" ] && show_help "Temporary folder not set."
[ ! -d "$SRC_DIR" ] && show_help "Source folder does not exist."
[ ! -d "$TEMP_DIR" ] && show_help "Temporary folder does not exist."
SUFF_PATTERN=".*\.($( sed -e "s/,/|/g" <<< $MATCH_SUFFIX))$"
if [ $VERBOSE == 1 ]; then
cat << EOF
=============================================================================
SRC_DIR      = $SRC_DIR
TEMP_DIR     = $TEMP_DIR
REPLACE_WS   = $REPLACE_WHITESPACE
SUFFIXES     = $MATCH_SUFFIX
SUFFIX_REGEX = $SUFF_PATTERN
SYNC         = $SYNC
=============================================================================
EOF
fi

find "$SRC_DIR" -type f | grep -E "$SUFF_PATTERN" | while read fin; do
    # prepare filenames
    fin_base=$( basename "$fin" )
    echo -e "\n$( tr "[:lower:]" "[:upper:]" <<< "$fin_base" )"
    fin_base_nosfx=$( basename "$fin" | sed -re "s/\.[^\.]+$//" )
    fout_base=$( sed -re "s/[ ]+/_/g" <<< $fin_base_nosfx | tr "[:upper:]" "[:lower:]" )
    # check if rename is required
    [ "$fin_base_nosfx" == "$fout_base" ] && req_rename=0 || req_rename=1
    if [ $req_rename == 1 ] && [ $VERBOSE == 1 ]; then
        echo "-- ☒ rename $fin_base_nosfx -> $fout_base"
    fi
    # check if conversion is required
    fin_suff=$( sed -e "s/.*\.//" <<< "$fin_base" )
    [ "$fin_suff" == "mp3" ] && req_conv=0 || req_conv=1
    if [ $req_conv == 1 ] && [ $VERBOSE == 1 ]; then
        echo "-- ☒ convert $fin -> $fout_base.mp3"
    fi
    # check if target file present
    if [ -f "${TEMP_DIR}/$fout_base.mp3" ]; then
        if [ $VERBOSE == 1 ]; then
            echo "-- ☑ $fout_base.mp3 present"
        fi
        continue
    fi
    # copy already converted and renamed files
    if [ $req_conv == 0 ] && [ $req_rename == 0 ]; then
        cp --preserve=all "$fin" "${TEMP_DIR}/$fout_base.mp3"
        echo "-- ☑ $fin copied"
        continue
    fi
    # rename already converted files
    if [ $req_conv == 0 ] && [ $req_rename == 1 ]; then
        cp --preserve=all "$fin" "${TEMP_DIR}/$fout_base.mp3"
        echo "-- ☑ $fin copied as $fout_base.mp3"
        continue
    fi
    # convert required files
    if [ $req_conv == 1 ]; then
        ffmpeg -i "$fin" -ab 192k "${TEMP_DIR}/$fout_base.mp3" \
        </dev/null 2>&1 > /dev/null
        echo "-- ☑ $fin converted to $fout_base.mp3"
        continue
    fi
done

if [ $SYNC == 1 ]; then
    rsync --archive --delete --stats "$TEMP_DIR" "$SRC_DIR"
fi
