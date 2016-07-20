#!/bin/sh

##### Constants #####
PRINTK_NONE="1 1 1 1"
UPDATE_FS=rootfs-update

##### External Scripts #####
. "/etc/init.d/printing_functions.sh"

##### Main #####
# Save printk configuration
printk_config=$(cat /proc/sys/kernel/printk)
title "Updating user space"
announce "Mounting update disk"
echo $PRINTK_NONE > /proc/sys/kernel/printk
mount -o loop /media/source/$UPDATE_FS /media/rootfs/usr/local/mydebs/
echo $printk_config > /proc/sys/kernel/printk
announce "Installing packages"
mount -t proc none /media/rootfs/proc
mount -o bind /dev /media/rootfs/dev
chroot /media/rootfs /usr/local/mydebs/install.sh > /dev/null 2>&1
sync
