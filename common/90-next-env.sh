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

. "${SCR_PATH}/board_params.sh"

# Extract the U-Boot environment configuration section from the configuration file
sed '1,/^\[ fw_env.config/d;/^\[/,$d' ${CONFIG_FILE} > /etc/fw_env.config
# Extract the installation media boot command
first_boot=`grep first_boot= ${CONFIG_FILE} | cut -d= -f2-`
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
