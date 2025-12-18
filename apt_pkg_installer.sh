#!/bin/bash
#
# apt_pkg_installer
#

list_installer(){
	local -n ref="$1"
	echo -e "->Install apt list." 1>&2
	for pkg in "${ref[@]}"; do
		sudo apt install "${pkg}" 1>&2
	done
}

allay_numbered_display(){
    local -n ref
    local title
    ref="$1"; title="$2"
	echo -e "All $title version." 1>&2
	for pkg in "${ref[@]}"; do
		echo "${pkg}" 1>&2
	done
	echo 1>&2
}

#Works only when IFS is \n.
parse_list_output(){
	local word opt
	word="$1"; opt="$2"
	echo | apt list $opt 2>/dev/null | grep $word | nl -w 1 -s ' : '
}

get_package_names(){
	local pkg=${1%/*}
	pkg=${pkg##* }
	echo $pkg
}

#Provides an installation dialog for apt packages.
install_dialog(){
	while getopts fht:w: opt; do
		case "$opt" in
		t)
			local title="${OPTARG}"
			;;
		w)
			local word="${OPTARG}"
		esac
	done
	_IFS=$IFS; IFS=$'\n'
	local list=($(parse_list_output $word))
	local _list=($(parse_list_output $word --installed))
	IFS=$_IFS
	local len="${#list[@]}"
	local _len="${#_list[@]}"
	echo -e "\nInstall $title." 1>&2
	if [ $len -gt $_len ]; then
		allay_numbered_display list $title
		read -ep "Want to install another version? Press Skip on Enter. : " i
		if [[ $i -gt 0 ]]; then
			if [[ $i -gt $len ]]; then echo "Invalid number,skip installation." 1>&2; return 0; fi
			i=$(($i-1))
			echo $(get_package_names "${list[$i]}")
			return 0
		else
			echo "skip $title installation." 1>&2
			return 0
		fi
	else
		if [ 0 -eq $_len ]; then echo $(get_package_names "${list[0]}");return 0 ; fi
	fi
	echo -e "$title is already installed.\n" 1>&2
}

apt_pkg_installer(){
	array_length=$(jq '.pkg | length' pkglist.json)
	local i=0
	local -a APT_LIST
	echo -e "Install the required aptpackage in advance. \nChoose the version number from the multiple versions."
	while [ "$i" -lt "$array_length" ]; do
		elements=$(jq -r ".pkg[$i]" pkglist.json)
		if ! [ -z "$elements" ]; then
			name=$(echo "$elements" | jq -r ".name")
			query=$(echo "$elements" | jq -r ".query")
			APT_LIST+=(`install_dialog -w "$query" -t "$name"`)
		else
			break
		fi
		i=$((i + 1))
	done
	list_installer APT_LIST
}
