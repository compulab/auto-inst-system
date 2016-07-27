NORMAL="\033[0m"
GREEN="\033[32;1m"

title() {
	echo -e "${GREEN}===${1}===${NORMAL}"
}

announce() {
	echo -e "${GREEN}* ${NORMAL}${1}"
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

mount_partitions() {
	announce "Mounting partitions"
	# Mount source partition
	mkdir -p ${SOURCE_MOUNT_PATH} && mount ${SOURCE_MEDIA} ${SOURCE_MOUNT_PATH}
	# Mount order is important
	# Mount root partition
	if [ ! -z ${DESTINATION_FILESYSTEM_MEDIA} ];then
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
	[ -z $1 ] && patt=${SOURCE_MOUNT_PATH}/${FILESYSTEM_ARCHIVE_NAME} || patt=$1
	which pv &>/dev/null
	_pv=$?
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
	umount -l ${SOURCE_MEDIA}
}
