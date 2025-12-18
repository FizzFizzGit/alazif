#
# hdoc - here document
#

#Generate the unitfile
unitgen(){
local unitfile=$(sudo cat << EOS
#
# unitfile - mcs daemon unit file.
#
[Unit]
Description=Minecraft Server Service(${NAME})

[Service]
Type=forking
User=${USR}
WorkingDirectory=`pwd`/${NAME}
ExecStart=/bin/bash -c "`pwd`/run.sh ${NAME} start"
ExecStop=/bin/bash -c "`pwd`/run.sh ${NAME} stop"
ExecReload=/bin/bash -c "`pwd`/run.sh ${NAME} reload"
TimeoutStartSec=60
TimeoutStopSec=60
TimeoutReloadSec=120
Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target

#END OF FILE
EOS
)
#SuccessExitStatus=143
#KillMode=control-group
#KillSignal=SIGTERM
#SendSIGHUP=yes
echo "${unitfile}" > "minecraft-$1.service"
}

#runconf
run_confgen(){
local runconf=$(cat << EOS
#
# runconf - mcs run conf.
#
# Configuration data used in wizards.
# Direct editing is not recommended.
# Conf name
NAME="$1"
# Java command location
JRE="$2"
# Server application file name
JAR="$3"
# Server application arguments
ARG="$4"
# Execution user
USR="$5"
# Connection port
PORT="$6"
# Wait time (seconds) when the server is stopped
WAIT="$7"
# Copy source
CPSRC="$8"
# Availability of daemon operation
DAEMON="$9"

#END OF FILE
EOS
)
echo "${runconf}" > ./conf/"$1".conf
}
