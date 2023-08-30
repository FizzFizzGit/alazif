#!/bin/bash
#
# run.sh - here document string
#
set -e

#guard syntax
cd `dirname $0`
source ./core/lib

on_error(){
	echo "[Err] ${BASH_SOURCE[1]}:${BASH_LINENO} - '${BASH_COMMAND}' failed" 1>&2
	exit
}
trap on_error ERR

if [ -f ./conf/"$1".conf ]; then
	if [ -d ./"$1" ]; then
		run_core "$1" "$2"
	else
		echo "/$1 is not found."
	fi
else
	echo ".conf file is not found."
fi

#run.sh END OF FILE
