#!/bin/bash

if [ -z ${platform} ];then
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
else
if [ ! -d platform/${platform} ];then
cat << eom
	Invalid platform ${platform}
eom
	exit 1
fi
fi
