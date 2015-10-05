#!/bin/bash

if [ ! -v $( command -v "bbc.sh" ) ]; then source bbc.sh; else exit; fi

#BASE_DIR="/cygdrive/d/Drive/Privat/Schach/Analyse"

if [ $# == 1 ]
then
	BASE_DIR="/cygdrive/t/drive/Privat/Schach/Analyse-Dev"
else
	BASE_DIR="/cygdrive/t/drive/Privat/Schach/Analyse"
fi

INCOMING_FOLDER="${BASE_DIR}/incoming"
SPLIT_FOLDER="${BASE_DIR}/split"
PGN_EXTRACT="${BASE_DIR}/pgn-extract-17-19.exe"
PGN_EXTRACT_ECO="${BASE_DIR}/pgn-extract-17-19_eco.txt"
echo "WORKING DIRECTORY: ${BASE_DIR}"

# mkdir -p $INCOMING_FOLDER
# rm -rf $SPLIT_FOLDER
# mkdir -p $SPLIT_FOLDER
#
# echo "SPLITTING $( find $INCOMING_FOLDER -type f -iname "*.pgn" | wc -l ) GAMES..."
# for pgn in $( find $INCOMING_FOLDER -type f -iname "*.pgn" )
# do
# 	echo $pgn
# 	bname=$( basename $pgn .pgn )
# 	#if [ -e ${SPLIT_FOLDER}/${bname}.pgn ]; then continue; fi
#
# 	tmp_dir=$( mktemp -d )
# 	cp $pgn $tmp_dir
# 	cd $tmp_dir
# 	games=$( $PGN_EXTRACT -#1 ${bname}.pgn 2>&1 | grep "matched" | awk '{print $1}' )
# 	if [ $games == 1 ]
# 	then
# 		cp $pgn $SPLIT_FOLDER
# 	else
# 		rm ${bname}.pgn
# 		for sub_pgn in $( ls ${tmp_dir}/*.pgn | sort -n )
# 		do
# 			printf -v pad "%03d" $( basename $sub_pgn .pgn )
# 			mv $sub_pgn ${SPLIT_FOLDER}/${bname}_${pad}.pgn
# 		done
# 	fi
# 	cd $INCOMING_FOLDER
# 	rm -rf $tmp_dir
# done
#
# echo "FIXING ..."
# for pgn in $( find $SPLIT_FOLDER -type f -iname "*.pgn" )
# do
#
# 	echo $pgn
# 	# events
# 	events=$( cat $pgn | grep -e "^[ ]*\[Event" | wc -l )
# 	if [ $events -le 0 ]
# 	then
# 		awk '/^[ ]*1\./{print "[Event \"?\"]"}1' ${pgn} > ${pgn}.tmp; mv ${pgn}.tmp ${pgn}
# 	fi
#
# 	# site
# 	site=$( cat $pgn | grep -e "^[ ]*\[Site" | wc -l )
# 	if [ $site -le 0 ]
# 	then
# 		awk '/^[ ]*1\./{print "[Site \"?\"]"}1' ${pgn} > ${pgn}.tmp; mv ${pgn}.tmp ${pgn}
# 	fi
#
# 	# eco code
# 	$PGN_EXTRACT -e$( cygpath -w $PGN_EXTRACT_ECO ) $( cygpath -w ${pgn}) 2> /dev/null > ${pgn}.tmp; mv ${pgn}.tmp ${pgn}
#
# 	# search and replace
# 	sed -i -e "s/basti_tee/Tschoepel, Sebastian/g" \
# 	-e "s/basti-tee/Tschoepel, Sebastian/g" \
# 	-e "s/PzudemS/Knobloch, Jens/g" \
# 	-e "s/Rababbelrabumm13/Ihle, Benjamin/g" \
# 	-e "s/rababbelrabumm/Ihle, Benjamin/g" \
# 	-e "s/mo14/Reinhardt, Moritz/g" \
# 	-e "s/hdaum/Daum, Heiko/g" \
# 	-e "s/sebo711/Schopen, Sebastian/g" \
# 	-e "s/Pitti_Platsch/Kukla, Alexander/g" \
# 	-e "s/Zebrilus/Luebke, Ulrich/g" \
# 	-e "s/DJTaim/Meyer, Thomas/g" ${pgn}
#
# done

echo "ASSEMBLING ..."
for pgn in $( find $SPLIT_FOLDER -type f -iname "*.pgn" )
do
	# echo $pgn
	grep --text -e "\[Site" -e "\[Event" $pgn | sort -r | tr "\n" " "
	echo ""
done
