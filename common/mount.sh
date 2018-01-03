# Automatic installation system
#
# Copyright (C) 2017 CompuLab, Ltd.
# Author: Uri Mashiach <uri.mashiach@compulab.co.il>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or later
# version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

UBIATTACH=$(which ubiattach &>/dev/null && which ubiattach || echo -n 'echo ubiattach')
UBIDETACH=$(which ubidetach &>/dev/null && which ubidetach || echo -n 'echo ubidetach')

mount_dev() {
	announce "$FUNCNAME [ $@ ]"
	dev=$1; mpoint=$2
	if [ -z "$dev" ] || [ -z $mpoint ];then
		err_msg ${FUNCNAME[0]}: empty parameters: dev=${dev} mpoint={mpoint}
		return 1
	fi
	mkdir -p ${mpoint}
	if [ $? -ne 0 ];then
		err_msg ${FUNCNAME[0]}: Failed to create directory: ${ret}
		err_msg ${FUNCNAME[0]}: failed cmd: mkdir -p ${mpoint}
		return ${ret}
	fi
	mount ${dev} ${mpoint}
	ret=0; if [ ${ret} -ne 0 ];then
		err_msg ${FUNCNAME[0]}: mount failure: ${ret}
		err_msg ${FUNCNAME[0]}: failed cmd: mount ${dev} ${mpoint}
		return ${ret}
	fi
}

umount_dev() {
	announce "$FUNCNAME [ $@ ]"
	dev_mpoint=$1
	if [ -z "$dev_mpoint" ];then
		err_msg ${FUNCNAME[0]}: dev_mpoint parameter is empty
		return 1
	fi
	umount -l ${dev_mpoint} &>/dev/null
}

mount_destination() {
	debug_msg "$FUNCNAME [ $@ ]"
	if [ ! -z ${NAND_PARAMS} ];then
		mount_destination_nand
	fi
	# Mount order is important
	# Mount root partition
	if [ -z "${DESTINATION_FILESYSTEM_MEDIA}" ];then
		err_msg ${FUNCNAME[0]}: variable DESTINATION_FILESYSTEM_MEDIA is empty
		return 1
	fi
	mkdir -p ${DESTINATION_FILESYSTEM_MOUNT_PATH}
	ret=$?; if [ ${ret} -ne 0 ];then
		err_msg ${FUNCNAME[0]}: failed to create directory: ${ret}
		err_msg ${FUNCNAME[0]}: failed cmd: mkdir -p ${DESTINATION_FILESYSTEM_MOUNT_PATH}
		return ${ret}
        fi
	mount ${DESTINATION_FILESYSTEM_MEDIA} ${DESTINATION_FILESYSTEM_MOUNT_PATH}
	ret=$?; if [ ${ret} -ne 0 ];then
		err_msg ${FUNCNAME[0]}: mount failure: ${ret}
		err_msg ${FUNCNAME[0]}: failed cmd: mount \
			${DESTINATION_FILESYSTEM_MEDIA} ${DESTINATION_FILESYSTEM_MOUNT_PATH}
		return ${ret}
	fi
	# Mount boot partition onto the rootfs/boot
	if [ -z ${DESTINATION_KERNEL_MEDIA} ];then
		return 0
	fi
	mkdir -p ${DESTINATION_KERNEL_MOUNT_PATH}
	ret=$?; if [ ${ret} -ne 0 ];then
		err_msg ${FUNCNAME[0]}: failed to create directory: ${ret}
		err_msg ${FUNCNAME[0]}: failed cmd: mkdir -p ${DESTINATION_KERNEL_MOUNT_PATH}
		return ${ret}
	fi
	mount ${DESTINATION_KERNEL_MEDIA} ${DESTINATION_KERNEL_MOUNT_PATH}
	ret=$?; if [ ${ret} -ne 0 ];then
		err_msg ${FUNCNAME[0]}: mount failure: ${ret}
		err_msg ${FUNCNAME[0]}: failed cmd: mount \
			${DESTINATION_KERNEL_MEDIA} ${DESTINATION_KERNEL_MOUNT_PATH}
		return ${ret}
	fi
}

unmount_destination() {
	debug_msg "$FUNCNAME [ $@ ]"
	if [ ! -z ${NAND_PARAMS} ];then
		umount_destination_nand
		return $?
	fi
	if [ -z ${DESTINATION_KERNEL_MEDIA} ]; then
		err_msg ${FUNCNAME[0]}: variable DESTINATION_KERNEL_MEDIA is empty
		return 1
	fi
	umount -l ${DESTINATION_KERNEL_MEDIA}
	if [ -z ${DESTINATION_FILESYSTEM_MEDIA} ];then
		err_msg ${FUNCNAME[0]}: variable DESTINATION_FILESYSTEM_MEDIA is empty
		return 1
	fi
	umount -l ${DESTINATION_FILESYSTEM_MEDIA}
}

unmount_partitions() {
	announce "Unmounting partitions"
	if [ -z ${DESTINATION_KERNEL_MEDIA} ];then
		err_msg ${FUNCNAME[0]}: variable DESTINATION_KERNEL_MEDIA is empty
		return 1
	fi
	umount -l ${DESTINATION_KERNEL_MEDIA}
	if [ -z ${DESTINATION_FILESYSTEM_MEDIA} ];then
		err_msg ${FUNCNAME[0]}: variable DESTINATION_FILESYSTEM_MEDIA is empty
		return 1
	fi
	umount -l ${DESTINATION_FILESYSTEM_MEDIA}
}

mount_destination_nand() {
	ubi_root=" -t ubifs ubi${UBI_DEV_ROOT}:${UBI_VOLNAME_ROOT}"
	# Overwright DESTINATION parameters for NAND update
	DESTINATION_KERNEL_MEDIA=
	DESTINATION_FILESYSTEM_MEDIA=${ubi_root}
}

umount_destination_nand() {
	umount -l ${DESTINATION_FILESYSTEM_MOUNT_PATH}
	ubi_detach ${UBI_DEV_ROOT}
}

ubi_attach() {
	debug_msg "$FUNCNAME [ $@ ]"
	mtd=$1; ubi=$2
	[ -z $mtd ] || [ -z $ubi ] && return
	${UBIATTACH} -m ${mtd} -d ${ubi} 1>&- 2>&-
	ret=$?; if [ ${ret} -ne 0 ];then
		err_msg ${FUNCNAME[0]}: ubiattach failure: ${ret}
		err_msg ${FUNCNAME[0]}: failed cmd: ${UBIATTACH} -m ${mtd} -d ${ubi}
		return ${ret}
	fi
}

ubi_detach() {
	debug_msg "$FUNCNAME [ $@ ]"
	ubi=$1
	[ -z $ubi ] && return
	${UBIDETACH} -d ${ubi}
	ret=$?; if [ ${ret} -ne 0 ];then
		err_msg ${FUNCNAME[0]}: ubidetach failure: ${ret}
		err_msg ${FUNCNAME[0]}: failed cmd: ${UBIDETACH} -d ${ubi}
		return ${ret}
	fi
}
