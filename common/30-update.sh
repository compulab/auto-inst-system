#!/bin/sh
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

##### Constants #####
PRINTK_NONE="1 1 1 1"
printk_config=$(cat /proc/sys/kernel/printk)
SCR_PATH=$(dirname $BASH_SOURCE)

SOURCE_MOUNT_PATH=/media/source
DESTINATION_FILESYSTEM_MOUNT_PATH=/media/rootfs
DESTINATION_KERNEL_MOUNT_PATH=${DESTINATION_FILESYSTEM_MOUNT_PATH}/boot
ROOTFS_FILE_UPDATE=*.update.tar.bz2
. "${SCR_PATH}/board_params.sh"
. "${SCR_PATH}/functions.sh"

## Preinstallation Sanicty Check ##
[ -z ${DESTINATION_MEDIA} ] && return 0
[ -z ${SOURCE_MEDIA} ] && return 0

stat ${SOURCE_MOUNT_PATH}/${ROOTFS_FILE_UPDATE} &>/dev/null || return 0

install_main () {
	mount_destination  || return $?
	extract_userspace "${SOURCE_MOUNT_PATH}/${ROOTFS_FILE_UPDATE}" || return $?
	unmount_destination || return $?
}

##### Main #####
title "Updating OS"
echo $PRINTK_NONE > /proc/sys/kernel/printk
install_main
ret=$?
echo $printk_config > /proc/sys/kernel/printk
return ${ret}
