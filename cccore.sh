#!/bin/bash
#
# cccore - confconf core.
#

#autoport
auto_port(){
	min=$1; max=$2; i=$min
	while true; do
		_IFS=$IFS; IFS=$'\n'
		port_test=$(echo | sudo netstat -apn | grep :$i)
		IFS=$_IFS
		if [ -z "${port_test[0]}" ]; then echo $i; exit; fi
		echo -e "$i is used in\n${port_test[@]}" 1>&2
		if [ $i -eq $max ]; then echo "No free port found." 1>&2; exit; fi
		i=$(($i+1))
	done
}

jar_fetch(){
	local path res ret
	while getopts 'f:u:w:' fetch; do
		case "${fetch}" in
		f)
			local file=${OPTARG}
			if [ -n "$usr" ]; then
				if [ ! -f $file ] || [[ `basename $file` != *.jar ]]; then break; fi
				path=`dirname $file`
				if [ ${CONF}!=$path ]; then cp $file ${CONF}; fi
				ret=`basename $file`
				break
			fi
			;;
		u)
			local usr=${OPTARG}
			if [ -n "$url" ]; then
				res=$(curl -Iso /dev/null $url -w "%{http_code}")
				if [ $res -ne 200 ] || [[ `basename $url` != *.jar ]]; then break; fi
				sudo -u $usr wget $url --quiet
				ret=`basename $url`
				break
			fi
			if [ -n "$file" ]; then
				if [ ! -f $file ] || [[ `basename $file` != *.jar ]]; then break; fi
				path `dirname $file`
				if [ ${CONF}!=$path ]; then cp $file $dir; fi
				ret=`basename $file`
				break
			fi
			;;
		w)
			local url=${OPTARG}
			if [ -n "$usr" ]; then
				res=$(curl -Iso /dev/null $url -w "%{http_code}")
				if [ $res -ne 200 ] || [[ `basename $url` != *.jar ]]; then break; fi
				sudo -u $usr wget $url --quiet
				ret=`basename $url`
				break
			fi
			;;
		esac
	done

	if [ -n "$ret" ]; then echo $ret; else exit 1; fi
}

#Conf name
conf_name_dialog(){
	local name
	while true; do
		read -ep "Enter conf name. : " name
		if [ -n $name ]; then
			if [ ! -d ./conf/$name.conf ]; then
				echo $name
				break
			else
				echo "Name already in use." 1>&2
			fi
		fi
	done
}

#Copy source
copy_source_dialog(){
	local cpsrc
	while true; do
		read -ep "Enter copy source, blank to default. : " cpsrc
		if [ -n "$cpsrc" ]; then
			if [ ! -f $cpsrc ]; then echo $cpsrc; break; fi
			echo "Source does not exist." 1>&2
		else
			echo "Create without copying." 1>&2
			break
		fi
	done
}

#Availability of daemon operation
daemon_dialog(){
	while true; do
		read -ep "Make it a Daemon?[Y/n] : " yn
		case $yn in
		[Yy])
			echo "true"
			break
			;;
		[Nn])
			echo "false"
			break
			;;
		*) echo "Enter y or n." 1>&2
		esac
	done
}

#Execution user
user_dialog(){
	local usr
	while true; do
		read -n1 -e -p "Use current user ? blank to default. : " usr
		if [ -z "$usr" ]; then
			echo "Use current user." 1>&2
			echo `whoami`
			break
		else
			if [ -n `getent passwd $usr` ]; then
				break
			else
				echo "invalid username." 1>&2
			fi
		fi
	done
}

#Java command location
java_command_dialog(){
	local jre
	while true; do
		read -n1 -ep "Use current JRE ? blank to default. : " jre
		if [ -z "$jre" ]; then
			echo "Use current JRE." 1>&2
			echo ${JRE}
			break
		else
			if [ -f $jre ]; then
				echo $jre
				break
			else
				echo "invalid path." 1>&2
			fi
		fi
	done
}

#Server application file name
server_jar_dialog(){
	local usr url jar file
	usr="$1"
	while true; do
		read -ep "Download server jar file?[Y/n] : " yn
		case $yn in
		[Yy])
			while true; do
				read -ep "Enter the URL of the server jar. : " url
				jar="$(jar_fetch -u $usr -w $url)"
				if [ -n "$jar" ]; then
					echo $jar
					break
				else
					echo "invalid URL." 1>&2
				fi
			done
			break
			;;
		[Nn])
			while true; do
				read -ep "Enter full path of server jar. : " file
				jar=`jar_fetch -u $usr -f $file`
				if [ -n "$jar" ]; then
					echo $jar
					break
				else
					echo "invalid path." 1>&2
				fi
			done
			break
			;;
		*)
			echo 'Enter y or n.' 1>&2
		esac
	done
}

#Option
option_dialog(){
	local arg
	read -ep "Enter the jar option, blank to default. : " arg
	if [ -n "$arg" ]; then echo $arg; return; fi
	echo "Use Defalut Option." 1>&2
	echo ${ARG}
}

#Connection port
port_dialog(){
	local port
	while true; do
		read -ep "Enter connection port, blank to Auto. : " port
		if [ -n "$port" ]; then
			port_test=$(auto_port $port $port)
			if [ -n "$port_test" ]; then
				echo $port
				break
			fi
		else
			echo "Auto." 1>&2
			echo "$(auto_port ${PORT_MIN} ${PORT_MAX})"
			break
		fi
	done
}

#Wait time (seconds) when the server is stopped
wait_dialog(){
	local wait
	read -ep "Enter number of seconds to pause, blank to default. : " wait
	if [ -n "$wait" ]; then echo $wait; return; fi
	echo "Use default." 1>&2
 	echo ${WAIT}
}
