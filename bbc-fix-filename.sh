#!/bin/sh

ALLOWED_CHARACTERS="a-zA-Z0-9_\.&äöüÄÖÜß-"
PROC_FAILED=0
TP_RED=$( tput setaf 1 )
TP_GREEN=$( tput setaf 2 )
TP_RES=$( tput sgr0 )
[ -z $( command -v tput ) ] && { TP_RED=""; TP_GREEN=""; TP_RES=""; }

echo_red () {
    echo "$TP_RED$@$TP_RES"
}

echo_green () {
    echo "$TP_GREEN$@$TP_RES"
}

[ $# -le 0 ] && { echo_red "No file path(s) provided."; exit 1; }
for file in $@
do
    [ ! -e "$file" ] && { echo "$file does not exist."; PROC_FAILED=1; }
done
[ $PROC_FAILED == 1 ] && { echo_red "Invalid files found."; exit 1; }
for file in $@
do
    if [ ! -z "$( echo "$file" | sed -e "s/[$ALLOWED_CHARACTERS]//g" )" ]
    then
        echo_red "$file"
        filen=$( echo "$file" | sed \
-e "s/[ ]\{1,\}/_/g" \
-e "s/[^$ALLOWED_CHARACTERS]//g" \
)
# -e "s/ä/ae/g" \
# -e "s/ö/oe/g" \
# -e "s/ü/ue/g" \
# -e "s/Ä/Ae/g" \
# -e "s/Ö/Oe/g" \
# -e "s/Ü/Ue/g" \
# -e "s/ß/ss/g" \
       
        echo -e "\t$filen"
        mv "$file" "$filen"
    else
        echo_green "$file"
    fi
done


