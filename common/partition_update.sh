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

NANDWRITE=$(which nandwrite &>/dev/null && which nandwrite || echo -n 'echo nandwrite')

copy_kernel_files() {
	announce "Copying kernel files"
	if [ ${DESTINATION_MEDIA_TYPE} == "nand" ];then
		copy_kernel_files_nand
		return $?
	fi
	files='*.dtb zImage*'
	for file in ${files};do
		stat ${SOURCE_MOUNT_PATH}/${file} &>/dev/null
		if [ $? -ne 0 ];then
			err_msg ${FUNCNAME[0]}: Invalid file: ${file}
		fi
		cp -v ${SOURCE_MOUNT_PATH}/${file} ${DESTINATION_KERNEL_MOUNT_PATH}
	done
}

extract_userspace() {
	if [ -z "$1" ];then
		patt=${SOURCE_MOUNT_PATH}/${FILESYSTEM_ARCHIVE_NAME}
	else
		patt=$1
	fi
	stat ${patt} &>/dev/null || return
	which pv &>/dev/null ; _pv=$?
	for _file in ${patt};do
		announce "Extracting user space $(basename $_file)"
		if [ $_pv -eq 0 ];then
			pv -f ${_file} | tar --numeric-owner -xpjf - -C \
				${DESTINATION_FILESYSTEM_MOUNT_PATH} && sync
		else
			tar --numeric-owner -xpjf ${_file} -C ${DESTINATION_FILESYSTEM_MOUNT_PATH} > /dev/null && sync
		fi
	done
}

nand_write() {
	debug_msg "$FUNCNAME [ $@ ]"
	dev=$1; src=$2; off=$3
	if [ -z $dev ] || [ -z $src ] || [ -z $off ];then
		err_msg ${FUNCNAME[0]}: invalid input parameters: dev=${dev} src={src} off={off}
		return 1
	fi
	mtd='/dev/mtd'${dev}
	${NANDWRITE} -p ${mtd} -s ${off} ${src} 1>&- 2>&-
	ret=$?; if [ ${ret} -ne 0 ];then
		err_msg ${FUNCNAME[0]}: nandwrite failure: ${ret}
		err_msg ${FUNCNAME[0]}: failed cmd: ${NANDWRITE} -p ${mtd} -s ${off} ${src}
		return ${ret}
	fi
}

copy_kernel_files_nand() {
	MTD_OFFS_KERNEL=`grep nand_kernel_offset= ${CONFIG_FILE} | cut -d= -f2-`
	if [ -z ${MTD_OFFS_KERNEL} ];then
		MTD_OFFS_KERNEL=0
	fi
	file='zImage*'
	stat ${SOURCE_MOUNT_PATH}/${file} &>/dev/null
	[ $? -ne 0 ] && return
	nand_write ${MTD_DEV_KERNEL} ${SOURCE_MOUNT_PATH}/${file} $MTD_OFFS_KERNEL || return $?
	DTB_FILE=`grep dtb_file= ${CONFIG_FILE} | cut -d= -f2-`
	# Device tree blob file is not mandatory
	[ -z ${DTB_FILE} ] && return
	MTD_DEV_DTB=`grep nand_dtb_mtd_dev= ${CONFIG_FILE} | cut -d= -f2-`
	if [ -z ${MTD_DEV_DTB} ];then
		err_msg ${FUNCNAME[0]}: missing configuration: nand_dtb_mtd_dev
		return 1
	fi
	MTD_OFFS_DTB=`grep nand_dtb_mtd_offset= ${CONFIG_FILE} | cut -d= -f2-`
	if [ -z ${MTD_OFFS_DTB} ];then
		MTD_OFFS_DTB=0
	fi
	DTB_FILE=${SOURCE_MOUNT_PATH}/${DTB_FILE}
	if [ ! -f ${DTB_FILE} ]; then
		err_msg ${FUNCNAME[0]}: device tree blob file ${DTB_FILE} not found
		return 1
	fi
	nand_write ${MTD_DEV_DTB} ${DTB_FILE} $MTD_OFFS_DTB || return $?
}
