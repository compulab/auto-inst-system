#!/bin/bash

mpoint=/tmp/_mount
tarfile=debian-armhf-image.tar.bz2
mfile=install.ext2
boart_param_file=/etc/init.d/board_params.sh

destination=""
all_devs=$(ls /sys/class/block/*/capability | awk -F"/" '($5~/sd|mmc/)&&($0=$5)')
avail_devs=""
cnt=0
source=""
mkdir -p ${mpoint}
for dev in ${all_devs};do
	((cnt++))
	for _dev in $(ls /dev/${dev}*);do
		mount $_dev ${mpoint} 2>/dev/null
		if [ $? -eq 0 ];then
			if [ -z $source ];then
				stat ${mpoint}/${mfile} &>/dev/null
				if [ $? -eq 0 ];then
					source=$_dev
					dev=""
					((cnt--))
				fi
			fi
		umount -l ${mpoint}
		[ -z $dev ] && break;
		fi
	done
	avail_devs=${avail_devs}" "$dev
done
rm -rf ${mpoint}

avail_devs="${avail_devs#"${avail_devs%%[![:space:]]*}"}"

if [ $cnt -eq 1 ];then
	destination="/dev/"${avail_devs}
else
	select_string=$(echo ${avail_devs}; echo "<<")
	PS3="select a destination device > "
	select i in $select_string; do
		case $i in
			"<<")
			exit
			break
			;;
			*)
			destination="/dev/"$i
			echo "destination device is "${destination}
			break
			;;
		esac
	done
fi
part_pref=$([[ ${destination} =~ "mmc" ]] &&  echo -n "p")

cat << eof > ${boart_param_file}
SOURCE_MEDIA=${source}
DESTINATION_MEDIA=${destination}
DESTINATION_KERNEL_MEDIA=${destination}${part_pref}1
DESTINATION_FILESYSTEM_MEDIA=${destination}${part_pref}2
FILESYSTEM_ARCHIVE_NAME=${tarfile}
eof
