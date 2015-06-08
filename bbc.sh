#!/bin/bash

################################################################################
# BASTI'S BASH COMMONS
#
# Best way to include is to add the script to your path and include with
# if [ ! -v $( command -v "bbc.sh" ) ]; then source bbc.sh; else exit; fi
#
################################################################################

function bbc_exe () {
	# Tests if a command does exist and, if yes, runs it. This comes in handy
	# if you are unsure whether a tool exists. 
	
	if [ ! -v $( command -v $1 ) ]
	then
		eval $@
	fi 
}

function bbc_print_xml () {
	# Pretty-prints an XML string to the command line. 
	
	bbc_exe tput setaf 2
	echo
	xmllint --format $1
	echo
	bbc_exe tput sgr 0
}

function bbc_run_psql () {
	# Runs a given postgresql command through the psql command line. 
	# ATTENTION: This method assumes that $PG_PASS $PG_USSER and $PG_DB 
	# are set somewhere in your script. 
	
	export PGPASSWORD=$PG_PASS
	psql -h localhost -t -F " " -A -c "$1" $PG_DB $PG_USER
}

function bbc_get_datetime () {
	# Returns a filesave datetime  timestamp to be used in files 
	
	date "+%Y%m%d-%H%M%S"
}

function bbc_whereami () {
	# Returns the location of the current script
	
	location=$( readlink -f $( dirname $0 ))
	echo ${location}/$( basename $0 )
}

################################################################################
# Internal script management 
################################################################################

show_help () {
	echo -e "\nUsage: `basename $0` [-e <message>]\n"
	echo -e "\t-l \t\tList all non-internal methods"
	echo -e "\t-e <message>\tExample argument. Only prints out your message."
	echo
	exit 1
}

while getopts "he:l" opt; do
    case "$opt" in
    h)
        show_help
        ;;
	e)  echo $OPTARG
		exit 0
        ;;
	l)	clear
		cat $( bbc_whereami ) | egrep "^function" -A3 | grep -e "^function" \
		-e "^[[:space:]]*#" | sed -r -e "s/#[ ]*//g" -e "s/ \(\) \{/\n/g" \
		-e "s/^(function.*)/\n$(bbc_exe "tput setaf 3")\1$(bbc_exe \
		"tput sgr 0")/g" 
		echo
		exit 0
		;;
	*)
		show_help
		;;
	esac
done