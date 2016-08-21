NORMAL="\033[0m"
GREEN="\033[32;1m"

FLASHERASE=$(which flash_erase &>/dev/null && which flash_erase || echo -n 'echo flash_erase')
NANDWRITE=$(which nandwrite &>/dev/null && which nandwrite || echo -n 'echo nandwrite')

UBIFORAMT=$(which ubiformat &>/dev/null && which ubiformat || echo -n 'echo ubiformat')
UBIATTACH=$(which ubiattach &>/dev/null && which ubiattach || echo -n 'echo ubiattach')
UBIDETACH=$(which ubidetach &>/dev/null && which ubidetach || echo -n 'echo ubidetach')
UBIMKVOL=$(which ubimkvol &>/dev/null && which ubimkvol || echo -n 'echo ubimkvol')
UBIROOT=' -t ubifs ubi0:rootfs'

title() {
	echo -e "${GREEN}===${1}===${NORMAL}"
}

announce() {
	echo -e "${GREEN}* ${NORMAL}${@}"
}

create_partitions() {
	announce "Updating partitions"
	mdev -s && umount ${DESTINATION_KERNEL_MEDIA} 1>&- 2>&- && umount ${DESTINATION_FILESYSTEM_MEDIA} 1>&- 2>&-
	echo -e "o\nn\np\n1\n2048\n204800\na\n1\nt\nc\nn\np\n2\n204801\n\nw\neof\n" | fdisk -u ${DESTINATION_MEDIA} > /dev/null
	# Refresh the device nodes
	mdev -s 1>&- 2>&- && umount ${DESTINATION_KERNEL_MEDIA} 1>&- 2>&- && umount ${DESTINATION_FILESYSTEM_MEDIA} 1>&- 2>&-
}

format_partitions() {
	announce "Formatting partitions"
	ln -sf /proc/mounts /etc/mtab
	mkfs.ext2 -L boot ${DESTINATION_KERNEL_MEDIA} 1>&- 2>&-
	mkfs.ext4 -L rootfs ${DESTINATION_FILESYSTEM_MEDIA} 1>&- 2>&-
}

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

copy_kernel_files() {
	announce "Copying kernel files"
	files='*.dtb zImage*'
	for file in ${files};do
	stat ${SOURCE_MOUNT_PATH}/${file} &>/dev/null
	[ $? -eq 0 ] && cp -v ${SOURCE_MOUNT_PATH}/${file} ${DESTINATION_KERNEL_MOUNT_PATH}
	done
}

extract_userspace() {
	[ -z "$1" ] && patt=${SOURCE_MOUNT_PATH}/${FILESYSTEM_ARCHIVE_NAME} || patt=$1
	stat ${patt} &>/dev/null || return
	which pv &>/dev/null ; _pv=$?
	for _file in ${patt};do
	announce "Extracting user space $(basename $_file)"
	if [ $_pv -eq 0 ];then
		pv ${_file} | tar --numeric-owner -xpjf - -C ${DESTINATION_FILESYSTEM_MOUNT_PATH} > /dev/null && sync
	else
		tar --numeric-owner -xpjf ${_file} -C ${DESTINATION_FILESYSTEM_MOUNT_PATH} > /dev/null && sync
	fi
	done
}

unmount_partitions() {
	announce "Unmounting partitions"
	[ ! -z ${DESTINATION_KERNEL_MEDIA} ] && umount -l ${DESTINATION_KERNEL_MEDIA}
	[ ! -z ${DESTINATION_FILESYSTEM_MEDIA} ] && umount -l ${DESTINATION_FILESYSTEM_MEDIA}
	[ ! -z ${SOURCE_MEDIA} ] && umount -l ${SOURCE_MEDIA}
}

flash_erase() {
	announce "$FUNCNAME [ $@ ]"
	dev=$1; off=$2; cnt=$3
	[ -z $dev ] || [ -z $cnt ] || [ -z $off ] && return
	mtd="/dev/mtd"${dev}
	${FLASHERASE} ${mtd} ${off} ${cnt} 1>&- 2>&- 
}

nand_write() {
	announce "$FUNCNAME [ $@ ]"
	dev=$1; src=$2; off=$3
	[ -z $dev ] || [ -z $src ] || [ -z $off ] && return
	mtd='/dev/mtd'${dev}
	${NANDWRITE} -p ${mtd} -s ${off} ${src} 1>&- 2>&-
}

ubi_format() {
	announce "$FUNCNAME [ $@ ]"
	dev=$1
	[ -z $dev ] && return
	mtd="/dev/mtd"${dev}
	${UBIFORAMT} --yes ${mtd} 1>&- 2>&-
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

ubi_mkvol() {
	announce "$FUNCNAME [ $@ ]"
	ubi=$1; name=$2
	[ -z $ubi ] || [ -z $name ] && return
	ubi='/dev/ubi'${ubi}
	${UBIMKVOL} ${ubi} -m -N ${name} 1>&- 2>&-
}
