#!/bin/bash

if [ ! -v $( command -v "bbc.sh" ) ]; then source bbc.sh; else exit; fi

function show_help () {
	# Prints out information to the script user
	# $1 = Exit code
  if [ $# -ge 2 ]; then echo $2; fi
	echo -e "\nUsage: `basename $0` -u <your_username> -o <target_folder> \
[-t <target_user>]\n"
	echo -e "\t-u <your_username>\tYour chess.com username."
  echo -e "\t-o <target_folder>\tTarget folder."
  echo -e "\t-t <target_user>\tchess.com username to be crawled."
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
  o) target_folder=$OPTARG
		;;
  o) target_user=$OPTARG
    ;;
	*)
		show_help 1
		;;
	esac
done

if [ -v $target_folder ]; then show_help 1 "Target folder not set."; fi
if [ -v $username ]; then show_help 1 "Username not set."; fi
bbc_askpass "enter chess.com password"
bbc_password=$( bbc_urlescape $bbc_password )
if [ -v $bbc_password ]; then show_help 1 "Password not set."; fi

if [ -v $target_user ]; then target_user=$username; fi

target_folder=${target_folder}/${target_user}
if [ -e ${target_folder} ]
then
  mv $target_folder ${target_folder}.$( bbc_get_datetime )
fi
mkdir -p ${target_folder}
cookiejar=${target_folder}/cookies.txt
archivefile=${target_folder}/archive.html
idfile=${target_folder}/game_ids.txt

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
bbc_log "session-id : '$sessid'"

page_pointer=1
while true
do
  curl \
  --request GET \
  --insecure \
  --header "Cookie: PHPSESSID=${sessid}; sm_dapi_session=1;" \
  --write-out "archive-request-response-code: %{http_code}\n" \
  --output ${archivefile} \
  --stderr /dev/null \
  "http://www.chess.com/home/game_archive?sortby=&show=live_blitz&member=${target_user}&page=${page_pointer}"

  cat ${archivefile} | grep "livechess/game?id=" |\
  sed -r -e "s/.*livechess\/game\?id=([^\"]+)\".*/\1/g" >> $idfile

  bbc_log "crawled page $page_pointer"
  bbc_log "last page: $last_page"
  if [ "$last_page" == "$page_pointer" ]; then break; fi

  # find out last page of pagination
  last_page=$( cat ${archivefile} | grep "class=\"pagination\"" | tr "<" "\n" |\
  grep "page=" | sed -r -e "s/.*page=([0-9]+)\".*/\1/g" | sort -nu | tail -n1 )
  if [ -v $last_page ]; then break; fi # no paging means only one page
  # point to next page
  page_pointer=$(( $page_pointer + 1 ))

done

no_games=$( cat $idfile | sort -u | wc -l )
bbc_log "found $no_games games in archive"

function download_pgn () {
  stderr_tmp=${target_folder}/games/${1}_dl.txt
  curl \
    --verbose \
    --request GET \
    --header "Cookie: sm_dapi_session=1; PHPSESSID=${sessid}" \
    --stderr ${stderr_tmp} \
    --output ${target_folder}/games/${1}.pgn \
    "http://www.chess.com/echess/download_pgn?lid=${1}"
  if [ -s ${stderr_tmp} ]
  then
    true_filename=$( cat ${stderr_tmp} |\
    grep "Content-Disposition: attachment;" | tail -n1 |\
    sed -r -e "s/.*filename=\"([^\"]+)\".*/\1/g")
    mv ${target_folder}/games/${1}.pgn ${target_folder}/games/${true_filename}
    mv ${stderr_tmp} ${target_folder}/games/${true_filename}.txt
  fi
  sleep 0.1
}

mkdir -p ${target_folder}/games
for lid in $( cat $idfile ); do download_pgn $lid; done

# fin
