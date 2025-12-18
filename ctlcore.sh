#!/bin/bash
#
# ctlcore - MineCraftServerControl core.
#

server_start(){
	local runner
	runner="sudo -u ${USR} screen -dmS mc${NAME}"
	$runner ${JRE} ${ARG} -jar ${CONF}/${NAME}/${JAR} --port ${PORT}
}

server_halt(){
	local runner pid
	runner="sudo -u ${USR} screen -S mc${NAME} -X"
	$runner stuff "say Stop the server for maintenance.Get ready now."'\015'
	sleep 1
	$runner stuff "say ${WAIT}s left."'\015'
	sleep ${WAIT}
	$runner stuff "kick @a Server is shutdown, Wait for a reboot."'\015'
	sleep 1
	$runner stuff "stop"'\015'
	#stop loop
	while true; do
    	pid=$(find /var/run/screen/S-${USR} -name *mc${NAME} || true)
    	if [[ -z $pid ]]; then
    		echo "Server Halt." 1>&2
    		return 0
    	else
    		echo 'Waiting : '$pid 1>&2
    		sleep 10
    	fi
	done
}

server_backup(){
	local runner bkdir
	psres=$(ps aux | grep mc${NAME} | grep -v grep | head -n 1 || true)
	if [[ -n $psres ]]; then echo "now running, abort backup." 1>&2; return; fi
	runner="sudo -u ${USR}"
	bkdir=${CONF}/${NAME}/world_backup/`date "+%Y_%m%d_%H"`
	if [ -d $bkdir ]; then return; fi
	$runner mkdir $bkdir
	$runner cp -ar ${CONF}/${NAME}/world/ $bkdir/
	$runner cp -ar ${CONF}/${NAME}/world_nether/ $bkdir/
	$runner cp -ar ${CONF}/${NAME}/world_the_end/ $bkdir/
	echo "Server Backup to $bkdir." 1>&2
}

run(){
	source ./conf/"$1".conf
	source ./core/coreconf

	cd ${NAME}
	case "$2" in
	start)
		server_start
		;;
	stop)
		server_halt
		;;
	reload)
		server_halt
		server_backup
		server_start
		;;
	backup)
		server_backup
		;;
	*)
		echo "start | stop | reload | backup" 1>&2
	esac
}
