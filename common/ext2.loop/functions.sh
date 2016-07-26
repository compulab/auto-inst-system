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
	mkdir -p ${DESTINATION_FILESYSTEM_MOUNT_PATH} && mount ${DESTINATION_FILESYSTEM_MEDIA} ${DESTINATION_FILESYSTEM_MOUNT_PATH}
	# Mount boot partition onto the rootfs/boot
	mkdir -p ${DESTINATION_KERNEL_MOUNT_PATH} && mount ${DESTINATION_KERNEL_MEDIA} ${DESTINATION_KERNEL_MOUNT_PATH}
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
	announce "Extracting user space"
	which pv &>/dev/null
	if [ $? -eq 0 ];then
	pv ${SOURCE_MOUNT_PATH}/${FILESYSTEM_ARCHIVE_NAME} | tar --numeric-owner -xpjf - -C ${DESTINATION_FILESYSTEM_MOUNT_PATH} > /dev/null && sync
	else
	tar --numeric-owner -xpjf ${SOURCE_MOUNT_PATH}/${FILESYSTEM_ARCHIVE_NAME} -C ${DESTINATION_FILESYSTEM_MOUNT_PATH} > /dev/null && sync
	fi
}

unmount_partitions() {
	announce "Unmounting partitions"
	umount ${DESTINATION_KERNEL_MEDIA}
	umount ${DESTINATION_FILESYSTEM_MEDIA}
	umount ${SOURCE_MEDIA}
}
