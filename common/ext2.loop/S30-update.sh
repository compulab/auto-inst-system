#!/bin/sh

##### Constants #####
PRINTK_NONE="1 1 1 1"
printk_config=$(cat /proc/sys/kernel/printk)

SOURCE_MOUNT_PATH=/media/source
DESTINATION_FILESYSTEM_MOUNT_PATH=/media/rootfs
DESTINATION_KERNEL_MOUNT_PATH=${DESTINATION_FILESYSTEM_MOUNT_PATH}/boot
ROOTFS_FILE_UPDATE=*.update.tar.bz2
. "/etc/init.d/board_params.sh"
. "/etc/init.d/functions.sh"

## Preinstallation Sanicty Check ##
[ $(basename $BASH_SOURCE) == $(basename $0) ] && EXIT="exit" || EXIT="return"
[ -z ${DESTINATION_MEDIA} ] && ${EXIT} 1
[ -z ${SOURCE_MEDIA} ] && ${EXIT} 2

##### Main #####
title "Updating OS"
echo $PRINTK_NONE > /proc/sys/kernel/printk
mount_partitions
extract_userspace "${SOURCE_MOUNT_PATH}/${ROOTFS_FILE_UPDATE}"
unmount_partitions
echo $printk_config > /proc/sys/kernel/printk
