#!/bin/sh

##### Constants #####
PRINTK_NONE="1 1 1 1"
printk_config=$(cat /proc/sys/kernel/printk)
SCR_PATH=/root/install

SOURCE_MOUNT_PATH=/media/source
DESTINATION_FILESYSTEM_MOUNT_PATH=/media/rootfs
DESTINATION_KERNEL_MOUNT_PATH=${DESTINATION_FILESYSTEM_MOUNT_PATH}/boot
. "${SCR_PATH}/board_params.sh"
. "${SCR_PATH}/functions.sh"

format_partitions() {
	announce "Formatting partitions"
#	flash_erase ${DESTINATION_MEDIA}3 0 0 1>&- 2>&-
        flash_erase ${DESTINATION_MEDIA}5 0 0 1>&- 2>&-
        flash_erase ${DESTINATION_MEDIA}6 0 0 1>&- 2>&-
	ubiattach -m 6 -d 0 1>&- 2>&-
	sleep 1
	ubimkvol /dev/ubi0 -m -N rootfs 1>&- 2>&-
}

mount_partitions() {
	announce "Mounting partitions"
	# Mount boot partition onto the rootfs/boot
        mkdir -p ${DESTINATION_FILESYSTEM_MOUNT_PATH} && mount -t ubifs ubi0:rootfs ${DESTINATION_FILESYSTEM_MOUNT_PATH} 1>&- 2>&-
}

copy_kernel_files() {
	announce "Copying kernel files"
#	nandwrite -p ${DESTINATION_MEDIA}3 ${SOURCE_MEDIA}/am335x-sbc-t335.dtb 1>&- 2>&-
        nandwrite -p ${DESTINATION_MEDIA}5 ${SOURCE_MEDIA}/${TARGET_KERNEL} 1>&- 2>&-
}

extract_userspace() {
	announce "Extracting user space"
	which pv &>/dev/null
	if [ $? -eq 0 ];then
	pv ${SOURCE_MEDIA}/${FILESYSTEM_ARCHIVE_NAME} | tar --numeric-owner -xpjf - -C ${DESTINATION_FILESYSTEM_MOUNT_PATH} > /dev/null && sync
	else
	tar --numeric-owner -xpjf ${SOURCE_MEDIA}/${FILESYSTEM_ARCHIVE_NAME} -C ${DESTINATION_FILESYSTEM_MOUNT_PATH} > /dev/null && sync
	fi
}

unmount_partitions() {
	announce "Unmounting partitions"
	umount ${SOURCE_MEDIA}
}

##### Main #####
title "Installing OS"
echo $PRINTK_NONE > /proc/sys/kernel/printk
format_partitions
mount_partitions
copy_kernel_files
extract_userspace
unmount_partitions
echo $printk_config > /proc/sys/kernel/printk
