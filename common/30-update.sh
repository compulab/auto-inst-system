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
[ $(basename $BASH_SOURCE) == $(basename $0) ] && EXIT="exit" || EXIT="return"
[ -z ${DESTINATION_MEDIA} ] && ${EXIT} 1
[ -z ${SOURCE_MEDIA} ] && ${EXIT} 2

stat ${SOURCE_MOUNT_PATH}/${ROOTFS_FILE_UPDATE} &>/dev/null || ${EXIT} 3

##### Main #####
title "Updating OS"
echo $PRINTK_NONE > /proc/sys/kernel/printk
mount_destination
extract_userspace "${SOURCE_MOUNT_PATH}/${ROOTFS_FILE_UPDATE}"
unmount_destination
echo $printk_config > /proc/sys/kernel/printk
