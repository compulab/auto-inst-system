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

tranlate_target_media() {
	local sd_i=0
	local emmc_i=0
	mmc_list=($(lsblk -dno name | grep mmcblk[0-9]*$))
	for (( i=0; i<=${#mmc_list[*]} - 1; i++ )); do
		# Skip if not in available devices list
		if [[ ! ${avail_devs[@]} =~ ${mmc_list[i]} ]]; then continue; fi
		# eMMC devices should be listed more then once because of the boot partitions
		mmc_count=$(lsblk -dn | grep ${mmc_list[i]} | wc -l)
		mmc_count=${mmc_count}
		if [[ ${mmc_count} -gt 1 ]];then
			emmc_list[emmc_i]=${mmc_list[i]}
			emmc_i=$((${emmc_i}+1))
		else
			sd_list[sd_i]=${mmc_list[i]}
			sd_i=$((${sd_i}+1))
		fi
	done

	readarray -t scsi_list <<< "$(lsblk -Sn)"
	IFS=$'\n'
	sata_list=($(for i in ${scsi_list[@]}; do echo ${i}; done | grep sata | awk '{print $1}'))
	sata_i=${#sata_list[@]}
	unset IFS
	for (( i=0; i<${#target_media[*]}; i++ )); do
		case ${target_media[i]} in
		sd)
			if [ ${sd_i} -gt 1 ];then
				err_msg ${FUNCNAME[0]}: multiple destination SD cards found
				exit 1
			elif [ ${sd_i} -eq 1 ];then
				target_media_trans[i]=${sd_list}
			else
				target_media_trans[i]=${target_media[i]}
			fi
			;;
	        eMMC)
			if [ ${emmc_i} -gt 1 ];then
				err_msg ${FUNCNAME[0]}: multiple destination eMMC media found
				exit 1
			elif [ ${emmc_i} -eq 1 ];then
				target_media_trans[i]=${emmc_list}
			else
				target_media_trans[i]=${target_media[i]}
			fi
			;;
		sata)
			if [ ${sata_i} -gt 1 ];then
				err_msg ${FUNCNAME[0]}: multiple destination sata media found
				exit 1
			elif [ ${sata_i} -eq 1 ];then
				target_media_trans[i]=${sata_list}
			else
				target_media_trans[i]=${target_media[i]}
			fi
			;;
		mtd)
			target_media_trans[i]=${target_media[i]}
			;;
	        *)
			err_msg  ${FUNCNAME[0]}:${target_media[i]}: invalid target media
			exit 1
	        esac
	done
}
