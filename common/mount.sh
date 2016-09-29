UBIATTACH=$(which ubiattach &>/dev/null && which ubiattach || echo -n 'echo ubiattach')
UBIDETACH=$(which ubidetach &>/dev/null && which ubidetach || echo -n 'echo ubidetach')

mount_dev() {
	announce "$FUNCNAME [ $@ ]"
	dev=$1; mpoint=$2
	[ -z "$dev" ] || [ -z $mpoint ] && return
	mkdir -p ${mpoint} && mount ${dev} ${mpoint}
}

umount_dev() {
	announce "$FUNCNAME [ $@ ]"
	dev_mpoint=$1
	[ -z "$dev_mpoint" ] && return
	umount -l ${dev_mpoint} &>/dev/null
}

mount_source() {
	announce "$FUNCNAME [ $@ ]"
	# Mount source partition
	if [ ! -z "${SOURCE_MEDIA}" ];then
		mkdir -p ${SOURCE_MOUNT_PATH} && mount ${SOURCE_MEDIA} ${SOURCE_MOUNT_PATH}
	fi
}

unmount_source() {
	announce "$FUNCNAME [ $@ ]"
	[ ! -z ${SOURCE_MEDIA} ] && umount -l ${SOURCE_MEDIA}
}

mount_destination() {
	announce "$FUNCNAME [ $@ ]"
	[ -z ${NAND_PARAMS} ] || mount_destination_nand 
	# Mount order is important
	# Mount root partition
	if [ ! -z "${DESTINATION_FILESYSTEM_MEDIA}" ];then
		mkdir -p ${DESTINATION_FILESYSTEM_MOUNT_PATH} && mount ${DESTINATION_FILESYSTEM_MEDIA} ${DESTINATION_FILESYSTEM_MOUNT_PATH}
	fi
	# Mount boot partition onto the rootfs/boot
	if [ ! -z ${DESTINATION_KERNEL_MEDIA} ];then
		mkdir -p ${DESTINATION_KERNEL_MOUNT_PATH} && mount ${DESTINATION_KERNEL_MEDIA} ${DESTINATION_KERNEL_MOUNT_PATH}
	fi
}

unmount_destination() {
	announce "$FUNCNAME [ $@ ]"
        [ -z ${NAND_PARAMS} ] || (umount_destination_nand; return)
	[ ! -z ${DESTINATION_KERNEL_MEDIA} ] && umount -l ${DESTINATION_KERNEL_MEDIA}
	[ ! -z ${DESTINATION_FILESYSTEM_MEDIA} ] && umount -l ${DESTINATION_FILESYSTEM_MEDIA}
}

unmount_partitions() {
	announce "Unmounting partitions"
	[ ! -z ${DESTINATION_KERNEL_MEDIA} ] && umount -l ${DESTINATION_KERNEL_MEDIA}
	[ ! -z ${DESTINATION_FILESYSTEM_MEDIA} ] && umount -l ${DESTINATION_FILESYSTEM_MEDIA}
	[ ! -z ${SOURCE_MEDIA} ] && umount -l ${SOURCE_MEDIA}
}

mount_partitions() {
	announce "Mounting partitions"
	# Mount source partition
	if [ ! -z "${SOURCE_MEDIA}" ];then
	mkdir -p ${SOURCE_MOUNT_PATH} && mount ${SOURCE_MEDIA} ${SOURCE_MOUNT_PATH}
	fi
	# Mount order is important
	# Mount root partition
	if [ ! -z "${DESTINATION_FILESYSTEM_MEDIA}" ];then
	mkdir -p ${DESTINATION_FILESYSTEM_MOUNT_PATH} && mount ${DESTINATION_FILESYSTEM_MEDIA} ${DESTINATION_FILESYSTEM_MOUNT_PATH}
	fi
	# Mount boot partition onto the rootfs/boot
	if [ ! -z ${DESTINATION_KERNEL_MEDIA} ];then
	mkdir -p ${DESTINATION_KERNEL_MOUNT_PATH} && mount ${DESTINATION_KERNEL_MEDIA} ${DESTINATION_KERNEL_MOUNT_PATH}
	fi
}

unmount_partitions() {
	announce "Unmounting partitions"
	[ ! -z ${DESTINATION_KERNEL_MEDIA} ] && umount -l ${DESTINATION_KERNEL_MEDIA}
	[ ! -z ${DESTINATION_FILESYSTEM_MEDIA} ] && umount -l ${DESTINATION_FILESYSTEM_MEDIA}
	[ ! -z ${SOURCE_MEDIA} ] && umount -l ${SOURCE_MEDIA}
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
	announce "$FUNCNAME [ $@ ]"
	mtd=$1; ubi=$2
	[ -z $mtd ] || [ -z $ubi ] && return
	${UBIATTACH} -m ${mtd} -d ${ubi} 1>&- 2>&-
}

ubi_detach() {
	announce "$FUNCNAME [ $@ ]"
	ubi=$1
	[ -z $ubi ] && return
	${UBIDETACH} -d ${ubi}
}
