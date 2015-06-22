#!/bin/bash

################################################################################
# BASTI'S BASH COMMONS
# Best way to include is to add the script to your path and include with
# if [ ! -v $( command -v "bbc.sh" ) ]; then source bbc.sh; else exit; fi
#
################################################################################

function bbc_yesno () {
	# Asks the user a yes/no question and returns 1 if 'yes' and 0 if 'no'
	# $1 = The question	read -p "$1 (y/n)" -n 1 -r
	echo "" # (optional) move to a new line
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		echo 1
	else
		echo 0
	fi	
}

function bbc_exe () {
	# Tests if a command does exist and, if yes, runs it. This comes in handy
	# if you are unsure whether a tool exists. 
	# $1 = Command to be executed 
	
	if [ ! -v $( command -v $1 ) ]
	then
		eval $@
	fi 
}

function bbc_print_xml () {
	# Pretty-prints an XML string to the command line. 
	# $1 = XML file 
	
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
	# $1 = PostgreSQL Query with escaped quotation marks 
	
	export PGPASSWORD=$PG_PASS
	psql -h localhost -t -F " " -A -c "$1" $PG_DB $PG_USER
}

function bbc_get_datetime () {
	# Returns a file-safe datetime timestamp to be used in files.
	
	date "+%Y%m%d-%H%M%S"
}

function bbc_whereami () {
	# Returns the location of the current script.
	
	location=$( readlink -f $( dirname $0 ))
	echo ${location}/$( basename $0 )
}

function bbc_get_filename () {
	# Returns filename without path and suffix from given filepath.
	# $1 = Path to file
	
	filename=$(basename "$1")
	echo ${filename%.*}
}

function bbc_get_filesuffix () {
	# Returns fie suffix without path and filename from given filepath.
	# $1 = Path to file
	
	filename=$(basename "$1")
	echo ${filename##*.}
}

function bbc_split_on_pattern () {
	# Splits a file on a given regex pattern into multiple files.
	# $1 = Input file
	# $2 = Regular expression to split file at 
	
	base=$( bbc_get_filename $1 )
	suff=$( bbc_get_filesuffix $1 )
	awk -v pat="$2" -v base=$base -v suff=$suff '$0 ~ pat { i++ }{ \
	print > base"."sprintf("%05d", i)"."suff }' ${1}
}

################################################################################
# COMMAND LINE PARSING RECIPES
################################################################################

function show_help () {
	# Prints out information to the script user
	# $1 = Exit code 
	
	echo -e "\nUsage: `basename $0` [-e <message>]\n"
	echo -e "\t-e <message>\tExample argument."
	echo
	exit $1 
}

function parse_command_line ()   {
	# Parses the command line for the given options and reacts appropriately.
	
	while getopts "he:l" opt; do
		case "$opt" in
		h)
			show_help 0
			;;
		e)  echo $OPTARG
			;;
		*)
			show_help 1
			;;
		esac
	done
}