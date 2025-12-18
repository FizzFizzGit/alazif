#!/bin/bash
current=$(date "+%s") #現在時刻
interval=$1
subject=$2
address=$3
if [ -f ./pan ]; then
	timer=$(($( head -n 1 ./pan ) + $interval )) #先頭のタイムスタンプ取得
	if [ $timer -lt $current ]; then
 		dat=`cat pan`
 		echo "$current" > pan #タイムスタンプで上書きする
 		echo "$dat" | mail -s "${subject}" $address #$datは改行を維持するためダブルクオーテーションで囲う
	else
 		cat - >> pan #標準入力をファイルに追記
	fi
else
	cat - | mail -s "${subject}" $address
	echo "$current" > pan #新しいファイルpanの先頭に現在のタイムスタンプを書き込む
fi
