#!/bin/sh

##### Constants #####
PRINTK_NONE="1 1 1 1"

##### Main #####
# Save printk configuration
printk_config=$(cat /proc/sys/kernel/printk)
echo "Install..."
echo "Updating partitions..."
echo $PRINTK_NONE > /proc/sys/kernel/printk
mdev -s && umount /dev/mmcblk0p1 1>&- 2>&- && umount /dev/mmcblk0p2 1>&- 2>&-
echo $printk_config > /proc/sys/kernel/printk
echo -e "o\nn\np\n1\n2048\n204800\na\n1\nt\nc\nn\np\n2\n204801\n\nw\neof\n" | fdisk -u /dev/mmcblk0 > /dev/null
# Refresh the device nodes
echo $PRINTK_NONE > /proc/sys/kernel/printk
mdev -s 1>&- 2>&- && umount /dev/mmcblk0p1 1>&- 2>&- && umount /dev/mmcblk0p2 1>&- 2>&-
echo $printk_config > /proc/sys/kernel/printk
echo "Format partitions ..."
ln -sf /proc/mounts /etc/mtab
mkfs.vfat -n boot /dev/mmcblk0p1 > /dev/null
mkfs.ext4 /dev/mmcblk0p2 1>&- 2>&-
echo "Mounting partitions ..."
# Mount source partition
mkdir -p /media/source && mount /dev/mmcblk1p1 /media/source
# Mount boot partition
mkdir -p /media/boot && mount /dev/mmcblk0p1 /media/boot
# Mount root partition
echo $PRINTK_NONE > /proc/sys/kernel/printk
mkdir -p /media/rootfs && mount /dev/mmcblk0p2 /media/rootfs
echo $printk_config > /proc/sys/kernel/printk
echo "Copy kernel files ..."
cp /media/source/*.dtb /media/boot && sync
cp /media/source/zImage* /media/boot && sync
echo "Extract user space ..."
tar --numeric-owner -xvpjf /media/source/debian-armhf-image.tar.bz2 -C /media/rootfs > /dev/null && sync

