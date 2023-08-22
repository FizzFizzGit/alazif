#!/bin/bash
#
# mcmake.sh - here document string
#
set -e

#guard syntax
if [ ! -f ./core/conf ]; then echo "Current Directory is not HOME." 1>&2; exit 1;fi
if [ ! -f ./conf/"$1".conf ]; then echo "$1.conf is not found."; exit; fi
source ./conf/"$1".conf
source ./core/slib
source ./core/lib

on_error(){
	echo "[Err] ${BASH_SOURCE[1]}:${BASH_LINENO} - '${BASH_COMMAND}' failed" 1>&2
	exit
}
trap on_error ERR

cat << EOS
*
* mcmake.sh - Make Server Environment
*
EOS
case "$2" in #Make environment.
create) #Create environment.
	echo -e "\n->Create environment"
	if [ -n "${PARENT}" ]; then
		sudo -u $USR cp -r ${CPSRC} `pwd`
	else
		envgen "$1"
	fi
	;;
delete) #Delete environment.
	echo -e "\n->Delete environment"
	if [ ! -d ./"$1" ]; then echo "./$1 is not found."; exit; fi
	rm -r ./"$1"
	;;
--);; #Through option.
*)
	echo "create | delete | --"
	exit
esac


case "$3" in #Register/Unregister systemd.
on)	#Register with systemd.
	echo -e "\n->Register systemd" 1>&2
	if "${DAEMON}"; then
		if [ -f /etc/systemd/system/minecraft-"$1".service ]; then exit; fi
		unitgen "$1"
		sudo mv minecraft-"$1".service /etc/systemd/system/
		sudo systemctl enable minecraft-"$1"
		sudo systemctl daemon-reload
	else
		echo "Daemon is set to false." 1>&2
	fi
	;;
off) #Unregister systemd.
	echo -e "\n->Unregister sytemd" 1>&2
	if "${DAEMON}"; then
		if [ -f /etc/systemd/system/minecraft-"$1".service ]; then exit; fi
		sudo rm /etc/systemd/system/minecraft-"$1".service
		sudo systemctl daemon-reload
	else
		echo "Daemon is set to false." 1>&2
	fi
	;;
reload) #Reload systemd.
	echo -e "\n->Reload systemd" 1>&2
	if "${DAEMON}"; then
		unitgen "$1"
		sudo mv minecraft-"$1".service /etc/systemd/system/
		sudo systemctl daemon-reload
	else
		echo "Daemon is set to false." 1>&2
	fi
	;;
--);; #Through option
*)
	echo "on | off | reload | --" 1>&2
	exit
esac

case "$4" in #Open/Close port
open) #Open port
	echo -e "\n->Open port" 1>&2
	sudo ufw allow ${PORT}/tcp;;
close) #Close port
	echo -e "\n->Close port" 1>&2
	sudo ufw delete allow ${PORT}/tcp;;
--);; #Through option
*)
	echo "open | close | --" 1>&2
esac

#mcmake.sh END OF FILE
