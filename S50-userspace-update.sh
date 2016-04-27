#!/bin/sh

##### Constants #####
PRINTK_NONE="1 1 1 1"
UPDATE_FS=rootfs-update

##### Main #####
# Save printk configuration
printk_config=$(cat /proc/sys/kernel/printk)
echo "Mounting update disk ..."
echo $PRINTK_NONE > /proc/sys/kernel/printk
mount /media/source/$UPDATE_FS /media/rootfs/usr/local/mydebs/
echo $printk_config > /proc/sys/kernel/printk
echo "Update user space file system..."
mount -t proc none /media/rootfs/proc
mount -o bind /dev /media/rootfs/dev
chroot /media/rootfs /usr/local/mydebs/install.sh 1>&- 2>&-
sync
