#!/bin/bash
# Example implementation of webserver framework script

# Include Webserver stub
if [ ! -v $( command -v "webserver" ) ]; then source webserver; else exit; fi

# Now we override the framework methods to implement our own business logic
function process_GET () {
	# Override to implement your business logic
	echo -e "HTTP/1.1 200 OK\r"
	echo "Content-type: text/html"
	echo # IMPORTANT !

	extract_query_parameters $@

	for i in "${!qparams[@]}"
	do
	  wecho "KEY:   $i"
	  wecho "VALUE: ${qparams[$i]}"
	done
	wecho "======"
	wecho "${qparams[a]} + ${qparams[b]} = $(( ${qparams[a]} + ${qparams[b]} ))"

}

function process_POST () {
	# We don't allow POST requests
	echo -e "HTTP/1.1 405 Method not allowed\r"
}

start_server # firing up
# HINT: Restart server every five seconds for hot-code-replacement:
# while true; do timeout 5 webserver-example.sh -p1337; done
