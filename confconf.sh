#!/bin/bash
#
# confconf.sh - here document string
#
set -e

#guard syntax
if [ ! -f ./core/conf ]; then echo "Current Directory is not HOME." 1>&2; exit 1;fi
source ./core/conf
source ./core/slib
source ./core/lib

on_error(){
	echo "[Err] ${BASH_SOURCE[1]}:${BASH_LINENO} - '${BASH_COMMAND}' failed" 1>&2
	exit
}
trap on_error ERR

while getopts n:c:d:u:j:s:a:p:w: opt; do
	case "$opt" in
	n)
		name="${OPTARG}"
		;;
	c)
		cpsrc="${OPTARG}"
		;;
	d)
		daemon="${OPTARG}"
		;;
	u)
		usr="${OPTARG}"
		;;
	j)
		jre="${OPTARG}"
		;;
	s)
		jar="${OPTARG}"
		;;
	a)
		arg="${OPTARG}"
		;;
	p)
		port="${OPTARG}"
		;;
	w)
		wait="${OPTARG}"
	esac
done

cat << EOS
*
* confconf.sh - RunScript Config Wizard
*
EOS

if [ -z $name ]; then name="$(conf_name_dialog)"; echo; fi
if [ -z $cpsrc ]; then cpsrc="$(copy_source_dialog)"; echo; fi
if [ -z $daemon ]; then daemon="$(daemon_dialog)"; echo; fi
if [ -z $usr ]; then usr="$(user_dialog)"; echo; fi
if [ -z $jre ]; then jre="$(java_command_dialog)"; echo; fi
if [ -z $jar ]; then jar="$(server_jar_dialog $usr)"; echo; fi
if [ -z $arg ]; then arg="$(option_dialog)"; echo; fi
if [ -z $port ]; then port="$(port_dialog)"; echo; fi
if [ -z $wait ]; then wait="$(wait_dialog)"; echo; fi

#last check
cat << EOS
	Create a config file with the following settings.

		        NAME : $name
		         JRE : $jre
		         JAR : $jar
		         ARG : $arg
		        USER : $usr
		        PORT : $port
		        WAIT : $wait
		       CPSRC : $cpsrc
		      DAEMON : $daemon

EOS

while true; do
	read -ep "Make this?[Y/n]: " yn
	case $yn in
	[Yy])
		echo -e '\nOK.\n'
		break
		;;
	[Nn])
		echo -e '\nAbort.\n'
		exit
		;;
	*)
		echo -e '\nEnter y or n.\n'
	esac
done

run_confgen "$name" "$jre" "$jar" "$arg" "$usr" "$port" "$wait" "$cpsrc" "$daemon"

#confconf.sh END OF FILE
