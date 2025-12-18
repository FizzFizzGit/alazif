#!/bin/bash
#
# seed file
#

#Title
declare title=$(cat << EOS
MincraftServer Deploy Tool

     .S_SSSs    S.       .S_SSSs     sdSSSSSSSbs   .S    sSSs
    .SS~SSSSS   SS.     .SS~SSSSS    YSSSSSSSS%S  .SS   d%%SP
    S%S   SSSS  S%S     S%S   SSSS          S%S   S%S  d%S'
    S%S    S%S  S%S     S%S    S%S         S&S    S%S  S%S
    S%S SSSS%S  S&S     S%S SSSS%S        S&S     S&S  S&S
    S&S  SSS%S  S&S     S&S  SSS%S        S&S     S&S  S&S_Ss
    S&S    S&S  S&S     S&S    S&S       S&S      S&S  S&S~SP
    S&S    S&S  S&S     S&S    S&S      S*S       S&S  S&S
    S*S    S&S  S*b     S*S    S&S     S*S        S*S  S*b
    S*S    S*S  S*S.    S*S    S*S   .s*S         S*S  S*S
    S*S    S*S   SSSbs  S*S    S*S   sY*SSSSSSSP  S*S  S*S
    SSS    S*S    YSSP  SSS    S*S  sY*SSSSSSSSP  S*S  S*S
           SP                  SP                 SP   SP
           Y                   Y                  Y    Y

                                                      for bash
                 Installation preparation start
                        C-c to cancel

EOS
)

declare ending=$(cat << EOS

Initial setting is completed,
please read readme.txt for operation method.

EOS
)

#ResetScreen
alreset(){
	clear
	echo "$title"
}

#EndScript
alend(){
	echo "$ending"
	read -p "Enter to exit."
	clear
}

#Config file
conf_gen(){
touch core/conf.json
local conf=`pwd`
local JRE='`which java`'
local ARG='-Xms2G -Xmx4G'
jq ".conf = [.CONF = $conf, .JRE = $JRE, .ARG = $ARG, .PORT_MIN = 50000, .PORT_MAX = 60000, .WAIT = 30]" core/conf.json > core/conf.json
local conf=$(cat << EOS
#
# conf - confconf config file.
#
CONF=`pwd`
JRE='`which java`'
ARG='-Xms2G -Xmx4G'
PORT_MIN=50000
PORT_MAX=60000
WAIT=30

EOS
)
echo "${conf}" > core/conf.json
}

make_new_dir(){
	local str
	while true; do
		read -ep "Enter the new directory name. : " str
		if [ -z "$str" ]; then continue; fi
		if [ ! -d $str ]; then
			echo "Create new directory." 1>&2
			mkdir $str
			echo $str
			break
		else
			echo $str
			break
		fi
	done
}

#Use directory dialog
dir_dialog(){
	local ret
	while true; do
		read -ep "Use current directory?[Y/n] : " yn
		case $yn in
		[Yy])
			echo `pwd`
			break
			;;
		[Nn])
			ret=`make_new_dir`
			if [ -z $ret ]; then return 1; fi
			echo `pwd`/$ret
			break
			;;
		*)
			echo 'Enter y or n.' 1>&2
		esac
	done
}

#Start up
start_up(){
	local -a APT_LIST
	local org=`pwd`

	alreset
	echo "*First boot setting*"
	home=$(dir_dialog)
	mkdir $home/conf $home/core
	cd $home/core
	wget "https://github.com/FizzFizzGit/alazif/releases/download/v0.3pip/lib" --quiet
	wget "https://github.com/FizzFizzGit/alazif/releases/download/v0.3pip/slib" --quiet
	touch log
	cd $home
	wget "https://github.com/FizzFizzGit/alazif/releases/download/v0.3pip/confconf.sh" --quiet
	wget "https://github.com/FizzFizzGit/alazif/releases/download/v0.3pip/mcmake.sh" --quiet
	wget "https://github.com/FizzFizzGit/alazif/releases/download/v0.3pip/run.sh" --quiet
	wget "https://github.com/FizzFizzGit/alazif/releases/download/v0.3pip/README.md" --quiet
	conf_gen
	chmod a+x confconf.sh mcmake.sh run.sh

	alreset
	read -p "Do an availability check.Press Enter."
	apt_pkg_installer

	alreset
	read -ep "Would you like to create the environment now?[Y/n] : " yn
	case $yn in
	[Yy])
		alreset
		bash confconf.sh -n ${home##*/}
		alreset
		bash mcmake.sh ${home##*/} create -- --
	esac

	alreset
	alend
	cd $org
	rm alazif
	rm seed

}
