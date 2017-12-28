#!/bin/bash
#
# Automatic instalation system
#
# Copyright (C) 2017 CompuLab, Ltd.
# Author: Uri Mashiach <uri.mashiach@compulab.co.il>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or later
# version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

SCR_PATH=$(dirname $BASH_SOURCE)
mpoint=/tmp/_mount
tarfile=rootfs.tar.bz2
mfile=install.ext2
board_param_file=${SCR_PATH}/board_params.sh
source_mount_path=/mnt/install

destination=""
avail_devs=""
cnt=0
source=""
min_size_inb=2097152

. "${SCR_PATH}/functions.sh"

# Extract NAND parameters from cmdline
nand_params=`cat /proc/cmdline | tr " " "\n" | grep nand | cut -d"=" -f2`
if [ ! -z $nand_params ];then
	mtd_parts_no=`cat /proc/mtd | grep -cE "(((kernel|linux)|dtb)|rootfs)"`
	if [ ${mtd_parts_no} -ge 2 ];then
		avail_devs="mtd"
		((cnt++))
	fi
fi

all_devs=$(ls /sys/class/block/*/capability | awk -F"/" '($5~/sd|mmc/)&&($0=$5)')
mkdir -p ${mpoint}
for dev in ${all_devs};do
	# Device size check
	size=$(cat /sys/class/block/${dev}/size)
	[ $size -lt ${min_size_inb} ] && continue
	((cnt++))
	for _dev in $(ls /dev/${dev}*);do
		mount $_dev ${mpoint} 2>/dev/null
		if [ $? -eq 0 ];then
			# 1-st validation
			if [ -z $source ];then
				# make sure that the magic file is on the media
				# magic file is install.ext2
				stat ${mpoint}/${mfile} &>/dev/null
				if [ $? -eq 0 ];then
					source=$_dev
					# eliminate the device from the available device list
					dev=""
					((cnt--))
					# the rootfs tar ball has to be here
					# if not, clear the tarfile variable name
					# it makes the S10 script skip the entire
					# installation process
					[ ! -f ${mpoint}/${tarfile} ] && tarfile=""
				fi
			fi
		umount -l ${mpoint}
		[ -z $dev ] && break;
		fi
	done
	[ -z $dev ] || avail_devs=${avail_devs}" "$dev
done
rm -rf ${mpoint}

avail_devs="${avail_devs#"${avail_devs%%[![:space:]]*}"}"

if [ $cnt -eq 0 ];then
	err_msg $(basename $BASH_SOURCE): no destination media found
	return 1
elif [ $cnt -eq 1 ];then
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

if [ $destination != "/dev/mtd" ];then
	nand_params=
fi

cat << eof > ${board_param_file}
SOURCE_MOUNT_PATH=${source_mount_path}
DESTINATION_MEDIA=${destination}
DESTINATION_KERNEL_MEDIA=${destination}${part_pref}1
DESTINATION_FILESYSTEM_MEDIA=${destination}${part_pref}2
FILESYSTEM_ARCHIVE_NAME=${tarfile}
NAND_PARAMS=${nand_params}
eof
