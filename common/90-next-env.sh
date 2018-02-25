#!/bin/bash
#
# Automatic installation system
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
. "/tmp/board_params.sh"
. "${SCR_PATH}/functions.sh"

# Extract the U-Boot environment configuration section from the configuration file
regex_hex="^0[xX][[:xdigit:]]+$"
env_dev=`grep env_dev= ${CONFIG_FILE} | cut -d= -f2-`
if [ -z "${env_dev}" ]; then
	env_part_name=`grep env_part_name= ${CONFIG_FILE} | cut -d= -f2-`
	if [ -z "${env_part_name}" ]; then
		err_msg environment device parameters \"env_dev\" and \"env_part_name\" are missing
		return 1
	fi
	env_dev=`grep "${env_part_name}" /proc/mtd | cut -d: -f1`
	if [ -z "${env_dev}" ]; then
		err_msg environment partition \"${env_part_name}\" is missing
		return 1
	fi
fi
env_offset=`grep env_offset= ${CONFIG_FILE} | cut -d= -f2-`
if [ -z ${env_offset} ] || [[ ! ${env_offset} =~ ${regex_hex} ]]; then
       err_msg environment offset parameter \"env_offset\" is missing or invalid
       return 1
fi
if [ -z "${env_dev##*mtd*}"  ]; then
	env_size=`grep env_size= ${CONFIG_FILE} | cut -d= -f2-`
	if [ -z ${env_size} ] || [[ ! ${env_size} =~ ${regex_hex} ]]; then
		err_msg environment offset parameter \"env_size\" is missing or invalid
		return 1
	fi
	env_sector_size=`grep "${env_dev##*/}" /proc/mtd | cut -d" " -f3`
	if [ -z "${env_sector_size}" ]; then
		err_msg environment partition \"${env_dev}\" is missing
		return 1
	fi
fi
printf "/dev/${env_dev##*/}\t${env_offset}\t${env_size}\t0x${env_sector_size}\n" > /etc/fw_env.config

# Extract the installation media boot command
if [ -z "${DESTINATION_MEDIA_TYPE}" ]; then
	first_boot_key=first_boot
else
	first_boot_key=first_boot_${DESTINATION_MEDIA_TYPE}
fi
first_boot=`grep ${first_boot_key}= ${CONFIG_FILE} | cut -d= -f2-`
# Update root file system path
if [ ${DESTINATION_MEDIA_TYPE} != "nand" ];then
	first_boot=$(sed "s%root=[[:graph:]]*%root=${DESTINATION_FILESYSTEM_MEDIA}%" <<<${first_boot})
fi
# Extract the environment unlock device
unlock_dev=`grep unlock_dev= ${CONFIG_FILE} | cut -d= -f2-`
# Set environment variables bootcmd and bootcmd_next
[ -z "$unlock_dev" ] || flash_unlock $unlock_dev 0
fw_setenv bootcmd_next `fw_printenv -n bootcmd`
[ -z "$unlock_dev" ] || flash_unlock $unlock_dev 0
fw_setenv bootcmd "setenv bootcmd \"\$bootcmd_next\"; setenv bootcmd_next; saveenv; $first_boot"
[ -z "$unlock_dev" ] || flash_unlock $unlock_dev 0
# Update U-Boot environment
if [ -f ${SOURCE_MOUNT_PATH}/tmp-env-wa ]; then
	awk '{ key = $1; gsub(/=.*/, "", key); gsub(/.*=/, "", $1); command = "fw_setenv " key " \47" $0 "\47"; print command | "/bin/sh"}' ${SOURCE_MOUNT_PATH}/tmp-env-wa
	[ -z "$unlock_dev" ] || flash_unlock $unlock_dev 0
fi
