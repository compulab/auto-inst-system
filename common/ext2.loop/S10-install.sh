#!/bin/sh

##### Constants #####
PRINTK_NONE="1 1 1 1"
printk_config=$(cat /proc/sys/kernel/printk)

SOURCE_MOUNT_PATH=/media/source
DESTINATION_FILESYSTEM_MOUNT_PATH=/media/rootfs
DESTINATION_KERNEL_MOUNT_PATH=${DESTINATION_FILESYSTEM_MOUNT_PATH}/boot
. "/etc/init.d/board_params.sh"
. "/etc/init.d/functions.sh"

## Preinstallation Sanicty Check ##
[ $(basename $BASH_SOURCE) == $(basename $0) ] && EXIT="exit" || EXIT="return"
[ -z ${FILESYSTEM_ARCHIVE_NAME} ] && ${EXIT} 1
[ -z ${DESTINATION_MEDIA} ] && ${EXIT} 2
[ -z ${SOURCE_MEDIA} ] && ${EXIT} 3

stat ${SOURCE_MOUNT_PATH}/${FILESYSTEM_ARCHIVE_NAME} &>/dev/null || ${EXIT} 4

##### Main #####
title "Installing OS"
echo $PRINTK_NONE > /proc/sys/kernel/printk
create_partitions
format_partitions
mount_destination
copy_kernel_files
extract_userspace
unmount_destination
echo $printk_config > /proc/sys/kernel/printk
