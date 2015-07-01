#!/bin/bash

if [ ! -v $( command -v "bbc.sh" ) ]; then source bbc.sh; else exit; fi

function show_help () {
	# Prints out information to the script user
	# $1 = Exit code
  if [ $# -ge 2 ]; then echo $2; fi
	echo -e "\nUsage: `basename $0` -u <username> -o <targetfolder>\n"
	echo -e "\t-u <username>\tchess.com username"
  echo -e "\t-o <targetfolder>\tTarget folder"
	echo
	exit $1
}

while getopts "hu:o:" opt; do
	case "$opt" in
	h)
		show_help 0
		;;
	u) username=$OPTARG
		;;
  o) targetfolder=$OPTARG
		;;
	*)
		show_help 1
		;;
	esac
done

if [ -v $targetfolder ]; then show_help 1 "Target folder not set."; fi
if [ -v $username ]; then show_help 1 "Username not set."; fi
bbc_askpass "Enter chess.com password"
bbc_password=$( bbc_urlescape $bbc_password )
if [ -v $bbc_password ]; then show_help 1 "Password not set."; fi

cookiejar=${targetfolder}/cookies.txt
archivefile=${targetfolder}/archive.html
idfile=${targetfolder}/game_ids.txt

mkdir -p $targetfolder

response_code=$( curl \
--request POST \
--insecure \
--cookie-jar ${cookiejar} \
--write-out "%{http_code}\n" \
--data "loginusername=${username}&loginpassword=$bbc_password" \
--output /dev/null \
--stderr /dev/null \
https://www.chess.com/login )

if [ $response_code != 302 ]; then echo "Login seemed to have failed."; exit; fi
sessid=$( cat ${cookiejar} | tail -n1 | awk '{print $7}' )
bbc_log "SESSION ID : '$sessid'"

page_pointer=1
while true
do
  curl \
  --request GET \
  --insecure \
  --header "Cookie: PHPSESSID=${sessid}; sm_dapi_session=1;" \
  --write-out "ARCHIVE-REQUEST-RESPONSE-CODE: %{http_code}\n" \
  --output ${archivefile} \
  --stderr /dev/null \
  "http://www.chess.com/home/game_archive?sortby=&show=live_blitz&member=Pitti_Platsch&page=${page_pointer}"

  cat ${archivefile} | grep "livechess/game?id=" |\
  sed -r -e "s/.*livechess\/game\?id=([^\"]+)\".*/\1/g" >> $idfile

  bbc_log "crawled page $page_pointer"
  bbc_log "last page: $last_page"
  if [ "$last_page" == "$page_pointer" ]; then break; fi

  # find out last page of pagination
  last_page=$( cat ${archivefile} | grep "class=\"pagination\"" | tr "<" "\n" |\
  grep "page=" | sed -r -e "s/.*page=([0-9]+)\".*/\1/g" | sort -nu | tail -n1 )
  # point to next page
  page_pointer=$(( $page_pointer + 1 ))

done

no_games=$( cat $idfile | sort -u | wc -l )
bbc_log "found $no_games games in archive"

# cat $idfile | xargs -P1 -I {} curl \
#   --verbose \
#   --request GET \
#   --header "Cookie: sm_dapi_session=1; PHPSESSID=${sessid}" \
#   --header "User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.130 Safari/537.36" \
#   --output ${target_folder}/{}.pgn "http://www.chess.com/echess/download_pgn?lid={}"

# form_state=$( cat $archivefile | grep "FormState" | sed -r -e "s/.*value=\"([^\"]+)\".*/\1/g" )
# echo $form_state

# game_one=$( head -n1 $idfile)
# echo "game1: $game_one"
# curl \
# --verbose \
# --request POST \
# --header "Cookie: sm_dapi_session=1; PHPSESSID=${sessid}" \
# --header "User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.130 Safari/537.36" \
# --write-out "PGN-REQUEST-RESPONSE-CODE: %{http_code}\n" \
# --output test.html \
# --data "gamearchivecheckbox${game_one}=on&Qform__FormControl=c21&Qform__FormEvent=QClickEvent&Qform__FormParameter=&Qform__FormCallType=Server&Qform__FormUpdates=&Qform__FormState=${form_state}&Qform__FormId=GameArchiveForm" \
# "http://www.chess.com/home/game_archive?sortby=&show=live_blitz&member=Pitti_Platsch"
