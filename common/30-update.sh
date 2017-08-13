#!/bin/sh

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
