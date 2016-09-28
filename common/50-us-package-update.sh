#!/bin/sh
# User space update with package image

##### Constants #####
PRINTK_NONE="1 1 1 1"
PRINTK_CONFIG=$(cat /proc/sys/kernel/printk)
PACKAGE_IMG=/media/source/rootfs-update
IMG_MOUNT_PATH=/media/rootfs/usr/local/mydebs/
SCR_PATH=/root/install
DESTINATION_FILESYSTEM_MOUNT_PATH=/media/rootfs
DESTINATION_KERNEL_MOUNT_PATH=${DESTINATION_FILESYSTEM_MOUNT_PATH}/boot

##### External Scripts #####
. "${SCR_PATH}/functions.sh"

## Preinstallation Sanicty Check ##
[ $(basename $BASH_SOURCE) == $(basename $0) ] && EXIT="exit" || EXIT="return"
[ -f ${PACKAGE_IMG} ] || ${EXIT} 1

##### Main #####
# Save printk configuration
title "Updating user space"
announce "Mounting package update image"
echo $PRINTK_NONE > /proc/sys/kernel/printk
mount_destination
[ -d ${IMG_MOUNT_PATH} ] || ${EXIT} 2
mount -o loop $PACKAGE_IMG $IMG_MOUNT_PATH
announce "Installing packages"
mount -t proc none /media/rootfs/proc
mount -o bind /dev /media/rootfs/dev
cmd_progr chroot /media/rootfs /usr/local/mydebs/install.sh
sync
announce "Un-mounting package update image"
umount $IMG_MOUNT_PATH
unmount_destination
echo $PRINTK_CONFIG > /proc/sys/kernel/printk
