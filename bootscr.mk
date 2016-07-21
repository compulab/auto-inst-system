#!/bin/bash

platform=""
select_string=$(ls platform/; echo "<<")
PS3="select a platform > "
select i in $select_string; do
	case $i in
		"<<")
		exit
		break
		;;
		*)
		platform=$i
		break
		;;
	esac
done

ibootscr=bootscr.in
obootscr=bootscr.img
cat platform/${platform}/*.scr common/*.scr > ${ibootscr}
mkimage -C none -O Linux -A arm -T script -d ${ibootscr} ${obootscr}
# clean up
[ -f ${ibootscr} ] && rm ${ibootscr}
