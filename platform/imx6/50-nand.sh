#!/bin/sh

##### Constants #####
PRINTK_NONE="1 1 1 1"
printk_config=$(cat /proc/sys/kernel/printk)
SCR_PATH=$(dirname $BASH_SOURCE)

SOURCE_MOUNT_PATH=/media/source
DESTINATION_FILESYSTEM_MOUNT_PATH=/media/rootfs
DESTINATION_KERNEL_MOUNT_PATH=${DESTINATION_FILESYSTEM_MOUNT_PATH}/boot
. "${SCR_PATH}/board_params.sh"
. "${SCR_PATH}/functions.sh"

ROOTFS_NAND_FILE="*.nand.tar.bz2"

MTD_ENV_DEV=1
MTD_BOOT_DEV=3
# KOFF/TOFF kernel/device-tree mtd offsets
MTD_BOOT_DEV_KOFF=0
MTD_BOOT_DEV_TOFF=0x780000
MTD_ROOT_DEV=4

UBI_ROOT_DEV=0
UBI_VOL_NAME=rootfs
UBIROOT=' -t ubifs ubi0:rootfs'

IMX6_KERNEL=zImage-cm-fx6
IMX6_DTREE=imx6q-sbc-fx6.dtb

# Overwright DESTINATION parameters for NAND update
DESTINATION_KERNEL_MEDIA=
DESTINATION_FILESYSTEM_MEDIA=${UBIROOT}

## Preinstallation Sanicty Check ##
[ -z ${SOURCE_MEDIA} ] && return 0

stat ${SOURCE_MOUNT_PATH}/${ROOTFS_NAND_FILE} &>/dev/null || return 0

##### Main #####
title "NAND Deployment"
echo $PRINTK_NONE > /proc/sys/kernel/printk
ubi_format ${MTD_ROOT_DEV}
ubi_attach ${MTD_ROOT_DEV} ${UBI_ROOT_DEV}
ubi_mkvol ${UBI_ROOT_DEV} ${UBI_VOL_NAME}
mount_destination

extract_userspace "${SOURCE_MOUNT_PATH}/${ROOTFS_NAND_FILE}"

flash_erase ${MTD_BOOT_DEV}
if [ -f ${DESTINATION_KERNEL_MOUNT_PATH}/${IMX6_KERNEL} ];then
nand_write  ${MTD_BOOT_DEV} ${DESTINATION_KERNEL_MOUNT_PATH}/${IMX6_KERNEL} ${MTD_BOOT_DEV_KOFF}
fi 

if [ -f ${DESTINATION_KERNEL_MOUNT_PATH}/${IMX6_DTREE} ];then
nand_write  ${MTD_BOOT_DEV} ${DESTINATION_KERNEL_MOUNT_PATH}/${IMX6_DTREE}  ${MTD_BOOT_DEV_TOFF}
fi

DESTINATION_FILESYSTEM_MEDIA=${DESTINATION_FILESYSTEM_MOUNT_PATH}
unmount_destination
ubi_detach ${UBI_ROOT_DEV}
echo $printk_config > /proc/sys/kernel/printk
