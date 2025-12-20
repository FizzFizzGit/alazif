#!/bin/bash
scr=$3
case $1 in
0)
	while true; do
		eval ${scr}
		sleep $2
	done
	;;
*)
	round=$(($1/$2))
	for ((i=0;i<$round;i++)); do
		eval ${scr}
		sleep $2
	done
esac
