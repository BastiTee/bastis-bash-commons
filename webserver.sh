#!/bin/bash
# A simple webserver framework written in Bash

# Include Basti's Bash Commons
if [ ! -v $( command -v "bbc.sh" ) ]; then source bbc.sh; else exit; fi
# We need bash v4 or later, because we want to use arrays
if [ $( bbc_get_bash_version | cut -b1 ) != 4 ]
then
	echo "Bash v4 is necessary"; exit 1
fi

declare -A qparams
export qparams

###############################################################################
# BUSINESS LOGIC STUBS (override these to implement your own server logic)
###############################################################################

function process_GET () {
	echo -e "HTTP/1.1 200 OK\r"
	echo "Content-type: text/html"
	echo # IMPORTANT !
	echo "GET-Request '$@' received. $( date )"
}

function process_POST () {
	echo -e "HTTP/1.1 200 OK\r"
	echo "Content-type: text/html"
	echo # IMPORTANT !
	echo "POST-Request '$@' received. $( date )"
}

###############################################################################
# HELPER METHODS
###############################################################################

function wecho () {
	# Web echo
	echo "$@<BR />"
}

function process_request () {
	if [ "$1" == "GET" ]
	then
		# no fancy favicons here - go away
		if [ "$2" == "/favicon.ico" ]; then echo -e "HTTP/1.1 404\r"; return; fi
		process_GET $@
	else
		process_POST $@
	fi
}

function extract_query_parameters () {
	request="$2"
	if [[ $request != *\?* ]]; then return; fi # no query param initiator
	request=$( echo $request | sed -r -e "s/^[^\?]+\?//g" )
	if [ -v $request ]; then return; fi # no query params
	for param in $( echo $request | tr "&" " " )
	do
		if [[ $param == *=* ]]
		then
			key=$( echo $param | tr "=" "\t" | cut -f1)
			value=$( echo $param | tr "=" "\t" | cut -f2)
			qparams[$key]=$value
		fi
	done
}

###############################################################################
# MAIN SERVER LOOP
###############################################################################

function start_server () {

	FIFO_PIPE_OUT=`mktemp`
	rm -f $FIFO_PIPE_OUT
	mkfifo $FIFO_PIPE_OUT
	bbc_log "Created output pipe at $FIFO_PIPE_OUT"
	trap "rm -f $FIFO_PIPE_OUT" EXIT
	bbc_log "Starting server on port $SERVER_PORT"

	while true
	do
		cat $FIFO_PIPE_OUT | nc -v -l $SERVER_PORT > >(
			request_uuid=$( uuidgen )
			while read line
			do
				echo $line
				if [[ $line == GET* ]] || [[ $line == POST* ]] # slow!
				then
					REQUEST=$line
				elif [ "$line" = "" ] # empty line / end of request
				then
					bbc_log "Processing request with uuid '$request_uuid': $REQUEST"
					process_request $REQUEST > $FIFO_PIPE_OUT
					bbc_log "Finished request processing for uuid '$request_uuid'"
				fi
			done
		)
	done
}

###############################################################################
# COMMAND LINE PARSING
###############################################################################

function show_help () {

	echo -e "\nUsage: `basename $0` [-p <port>]\n"
	echo -e "\t-p <port>\tServer port."
	echo
	exit $1
}

while getopts "hp:" opt; do
	case "$opt" in
	h)
		show_help 0
		;;
	p)
		SERVER_PORT=$OPTARG
		;;
	*)
		show_help 1
		;;
	esac
done
if [ -v $SERVER_PORT ]; then show_help 1; fi

# start_server # (for testing only)
