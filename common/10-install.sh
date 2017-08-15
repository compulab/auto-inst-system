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
. "${SCR_PATH}/board_params.sh"
. "${SCR_PATH}/functions.sh"

## Preinstallation Sanicty Check ##
[ $(basename $BASH_SOURCE) == $(basename $0) ] && EXIT="exit" || EXIT="return"
[ -z ${FILESYSTEM_ARCHIVE_NAME} ] && ${EXIT} 1
[ -z ${DESTINATION_MEDIA} ] && ${EXIT} 2
[ -z ${SOURCE_MEDIA} ] && ${EXIT} 3

stat ${SOURCE_MOUNT_PATH}/${FILESYSTEM_ARCHIVE_NAME} &>/dev/null || ${EXIT} 4

install_main () {
	create_partitions   || return $?
	format_partitions   || return $?
	mount_destination   || return $?
	copy_kernel_files   || return $?
	extract_userspace   || return $?
	unmount_destination || return $?
}

##### Main #####
title "Installing OS"
echo $PRINTK_NONE > /proc/sys/kernel/printk
install_main
ret=$?
echo $printk_config > /proc/sys/kernel/printk
return ${ret}
