#!/bin/sh

##### Constants #####
PRINTK_NONE="1 1 1 1"
printk_config=$(cat /proc/sys/kernel/printk)

SOURCE_MEDIA=/dev/mmcblk1p1
SOURCE_MOUNT_PATH=/media/source
DESTINATION_MEDIA=/dev/mmcblk0
DESTINATION_KERNEL_MEDIA=/dev/mmcblk0p1
DESTINATION_KERNEL_MOUNT_PATH=/media/boot
FILESYSTEM_ARCHIVE_NAME=debian-armhf-image.tar.bz2
DESTINATION_FILESYSTEM_MEDIA=/dev/mmcblk0p2
DESTINATION_FILESYSTEM_MOUNT_PATH=/media/rootfs
##### Main #####
echo "Install..."
echo "Updating partitions..."
echo $PRINTK_NONE > /proc/sys/kernel/printk
mdev -s && umount ${DESTINATION_KERNEL_MEDIA} 1>&- 2>&- && umount ${DESTINATION_FILESYSTEM_MEDIA} 1>&- 2>&-
echo $printk_config > /proc/sys/kernel/printk
echo -e "o\nn\np\n1\n2048\n204800\na\n1\nt\nc\nn\np\n2\n204801\n\nw\neof\n" | fdisk -u ${DESTINATION_MEDIA} > /dev/null
# Refresh the device nodes
echo $PRINTK_NONE > /proc/sys/kernel/printk
mdev -s 1>&- 2>&- && umount ${DESTINATION_KERNEL_MEDIA} 1>&- 2>&- && umount ${DESTINATION_FILESYSTEM_MEDIA} 1>&- 2>&-
echo $printk_config > /proc/sys/kernel/printk
echo "Format partitions ..."
ln -sf /proc/mounts /etc/mtab
mkfs.vfat -n boot ${DESTINATION_KERNEL_MEDIA} > /dev/null
mkfs.ext4 ${DESTINATION_FILESYSTEM_MEDIA} 1>&- 2>&-
echo "Mounting partitions ..."
# Mount source partition
mkdir -p ${SOURCE_MOUNT_PATH} && mount ${SOURCE_MEDIA} ${SOURCE_MOUNT_PATH}
# Mount boot partition
mkdir -p ${DESTINATION_KERNEL_MOUNT_PATH} && mount ${DESTINATION_KERNEL_MEDIA} ${DESTINATION_KERNEL_MOUNT_PATH}
# Mount root partition
echo $PRINTK_NONE > /proc/sys/kernel/printk
mkdir -p ${DESTINATION_FILESYSTEM_MOUNT_PATH} && mount ${DESTINATION_FILESYSTEM_MEDIA} ${DESTINATION_FILESYSTEM_MOUNT_PATH}
echo $printk_config > /proc/sys/kernel/printk
echo "Copy kernel files ..."
cp ${SOURCE_MOUNT_PATH}/*.dtb ${DESTINATION_KERNEL_MOUNT_PATH} && sync
cp ${SOURCE_MOUNT_PATH}/zImage* ${DESTINATION_KERNEL_MOUNT_PATH} && sync
echo "Extract user space ..."

tar --numeric-owner -xvpjf ${SOURCE_MOUNT_PATH}/${FILESYSTEM_ARCHIVE_NAME} -C ${DESTINATION_FILESYSTEM_MOUNT_PATH} > /dev/null && sync
