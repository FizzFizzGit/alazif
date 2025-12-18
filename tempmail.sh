#!/bin/bash

cd `dirname $0`
tlimit=60000 #警告温度
tsensor=`sudo cat /sys/class/thermal/thermal_zone2/temp`
temp=`echo "scale=1;$tsensor/1000" | bc` #小数点計算
if [[ $tsensor -gt $tlimit ]]; then
	echo `date`' over temp '$temp'℃'
	#日付と単位を付けてメール送信
	echo `date`' over temp '$temp'℃' | bash mayday.sh 300 "Temp Alart!" "fizz.from.outerspace@gmail.com"
else
	echo `date`' temp ok '$temp'℃'
fi
