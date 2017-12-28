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

FLASHERASE=$(which flash_erase &>/dev/null && which flash_erase || echo -n 'echo flash_erase')
UBIFORAMT=$(which ubiformat &>/dev/null && which ubiformat || echo -n 'echo ubiformat')
UBIMKVOL=$(which ubimkvol &>/dev/null && which ubimkvol || echo -n 'echo ubimkvol')
DD=$(which dd &>/dev/null && which dd || echo -n 'echo dd')
SFDISK=$(which sfdisk &>/dev/null && which sfdisk || echo -n 'echo sfdisk')
SFDISK_CONF_FILE_BLOCK=$(dirname $BASH_SOURCE)/sfdisk-block.conf

create_partitions() {
	announce "Updating partitions"
	if [ ! -z ${NAND_PARAMS} ];then
		return 0
	fi
	mdev -s 1>&- 2>&-
	umount ${DESTINATION_KERNEL_MEDIA} 1>&- 2>&-
	umount ${DESTINATION_FILESYSTEM_MEDIA} 1>&- 2>&-
	${DD} if=/dev/zero of=${DESTINATION_MEDIA} bs=1M count=1 1>&- 2>&-
	ret=$?;
	if [ ${ret} -ne 0 ];then
		err_msg ${FUNCNAME[0]}: failed to delete MBR: ${ret}
		err_msg ${FUNCNAME[0]}: failed cmd: \
			${DD} if=/dev/zero of=${DESTINATION_MEDIA} bs=1M count=1
		return ${ret}
	fi
	${SFDISK} -f ${DESTINATION_MEDIA} -uM < ${SFDISK_CONF_FILE_BLOCK} &> /dev/null
	ret=$?; if [ ${ret} -ne 0 ];then
		err_msg ${FUNCNAME[0]}: failed to create partitions: ${ret}
		err_msg ${FUNCNAME[0]}: failed cmd: \
			${SFDISK} -f ${DESTINATION_MEDIA} -uM < ${SFDISK_CONF_FILE_BLOCK}
		return ${ret}
	fi
	# Refresh the device nodes
	mdev -s 1>&- 2>&-
	umount ${DESTINATION_KERNEL_MEDIA} 1>&- 2>&-
	umount ${DESTINATION_FILESYSTEM_MEDIA} 1>&- 2>&-
	return 0
}

format_partitions() {
	announce "Formatting partitions"
	if [ ! -z ${NAND_PARAMS} ];then
		format_partitions_nand
		return $?
	fi
	ln -sf /proc/mounts /etc/mtab
	mkfs.ext2 -L boot ${DESTINATION_KERNEL_MEDIA} 1>&- 2>&-
	ret=$?; if [ ${ret} -ne 0 ];then
		err_msg ${FUNCNAME[0]}: failed to format partition: ${ret}
		err_msg ${FUNCNAME[0]}: failed cmd: mkfs.ext2 -L boot ${DESTINATION_KERNEL_MEDIA}
		return ${ret}
	fi
	mkfs.ext4 -L rootfs ${DESTINATION_FILESYSTEM_MEDIA} 1>&- 2>&-
	ret=$?; if [ ${ret} -ne 0 ];then
		err_msg ${FUNCNAME[0]}: failed to format partition: ${ret}
		err_msg ${FUNCNAME[0]}: failed cmd: mkfs.ext4 -L rootfs ${DESTINATION_FILESYSTEM_MEDIA}
		return ${ret}
	fi
}


flash_erase_f() {
	announce "$FUNCNAME [ $@ ]"
	dev=$1; off=$2; cnt=$3
	if [ -z $dev ] || [ -z $cnt ] || [ -z $off ] ; then
		err_msg ${FUNCNAME[0]}: missing parameters: dev=${dev} cnt=${cnt} off=${off}
		return 1
	fi
	mtd="/dev/mtd"${dev}
	${FLASHERASE} ${mtd} ${off} ${cnt} 1>&- 2>&-
	ret=$?; if [ ${ret} -ne 0 ];then
		err_msg ${FUNCNAME[0]}: flash_erase failure: ${ret}
		err_msg ${FUNCNAME[0]}:	failed cmd: ${FLASHERASE} ${mtd} ${off} ${cnt}
		return ${ret}
	fi
}

format_partitions_nand() {
	MTD_DEV_KERNEL=`echo $NAND_PARAMS | cut -d":" -f3`
	if [ -z $MTD_DEV_KERNEL ];then
		err_msg ${FUNCNAME[0]}: variable MTD_DEV_KERNEL is empty
		return 1
	fi
	flash_erase_f ${MTD_DEV_KERNEL} 0 0 || return $?
	mtd_dev_root=`echo $NAND_PARAMS | cut -d":" -f5`
	UBI_DEV_ROOT=`echo $NAND_PARAMS | cut -d":" -f6`
	UBI_VOLNAME_ROOT=`echo $NAND_PARAMS | cut -d":" -f7`
	if [ -z ${mtd_dev_root} ] || [ -z ${UBI_DEV_ROOT} ] || [ -z ${UBI_VOLNAME_ROOT} ];then
		err_msg ${FUNCNAME[0]}: invalid NAND parameters: NAND_PARAMS=${NAND_PARAMS}
		return 1
	fi
	ubi_format ${mtd_dev_root} || return $?
	ubi_attach ${mtd_dev_root} ${UBI_DEV_ROOT} || return $?
	ubi_mkvol ${UBI_DEV_ROOT} ${UBI_VOLNAME_ROOT} || return $?
	MTD_DEV_DTB=`echo $NAND_PARAMS | cut -d":" -f1`
	if [ -z $MTD_DEV_DTB ];then
                err_msg ${FUNCNAME[0]}: invalid NAND parameters: NAND_PARAMS=${NAND_PARAMS}
		return 1
	fi
	if [ ${MTD_DEV_DTB} -ne ${MTD_DEV_KERNEL} ];then
		flash_erase_f ${MTD_DEV_DTB} 0 0 || return $?
	fi
}

ubi_format() {
	announce "$FUNCNAME [ $@ ]"
	dev=$1
	[ -z $dev ] && return
	mtd="/dev/mtd"${dev}
	${UBIFORAMT} --yes ${mtd} 1>&- 2>&-
	ret=$?; if [ ${ret} -ne 0 ];then
		err_msg ${FUNCNAME[0]}: ubiformat failure: ${ret}
		err_msg ${FUNCNAME[0]}: failed cmd: ${UBIFORAMT} --yes ${mtd}
		return ${ret}
	fi
}

ubi_mkvol() {
	announce "$FUNCNAME [ $@ ]"
	ubi=$1; name=$2
	[ -z $ubi ] || [ -z $name ] && return
	ubi='/dev/ubi'${ubi}
	${UBIMKVOL} ${ubi} -m -N ${name} 1>&- 2>&-
	ret=$?; if [ ${ret} -ne 0 ];then
		err_msg ${FUNCNAME[0]}: ubimkvol failure: ${ret}
		err_msg ${FUNCNAME[0]}: failed cmd: ${UBIMKVOL} ${ubi} -m -N ${name}
		return ${ret}
	fi
}
