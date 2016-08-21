FLASHERASE=$(which flash_erase &>/dev/null && which flash_erase || echo -n 'echo flash_erase')
UBIFORAMT=$(which ubiformat &>/dev/null && which ubiformat || echo -n 'echo ubiformat')
UBIMKVOL=$(which ubimkvol &>/dev/null && which ubimkvol || echo -n 'echo ubimkvol')

create_partitions() {
	announce "Updating partitions"
	[ -z ${NAND_PARAMS} ] || return
	mdev -s && umount ${DESTINATION_KERNEL_MEDIA} 1>&- 2>&- && umount ${DESTINATION_FILESYSTEM_MEDIA} 1>&- 2>&-
	echo -e "o\nn\np\n1\n2048\n204800\na\n1\nt\nc\nn\np\n2\n204801\n\nw\neof\n" | fdisk -u ${DESTINATION_MEDIA} > /dev/null
	# Refresh the device nodes
	mdev -s 1>&- 2>&- && umount ${DESTINATION_KERNEL_MEDIA} 1>&- 2>&- && umount ${DESTINATION_FILESYSTEM_MEDIA} 1>&- 2>&-
}

format_partitions() {
	announce "Formatting partitions"
        [ -z ${NAND_PARAMS} ] || format_partitions_nand && return
	ln -sf /proc/mounts /etc/mtab
	mkfs.ext2 -L boot ${DESTINATION_KERNEL_MEDIA} 1>&- 2>&-
	mkfs.ext4 -L rootfs ${DESTINATION_FILESYSTEM_MEDIA} 1>&- 2>&-
}


flash_erase() {
	announce "$FUNCNAME [ $@ ]"
	dev=$1; off=$2; cnt=$3
	[ -z $dev ] || [ -z $cnt ] || [ -z $off ] && return
	mtd="/dev/mtd"${dev}
	${FLASHERASE} ${mtd} ${off} ${cnt} 1>&- 2>&- 
}

format_partitions_nand() {
	MTD_DEV_KERNEL=`echo $NAND_PARAMS | cut -d":" -f3`
	[ -z $MTD_DEV_KERNEL ] && return
	flash_erase ${MTD_DEV_KERNEL} 0 0
	mtd_dev_root=`echo $NAND_PARAMS | cut -d":" -f5`
	UBI_DEV_ROOT=`echo $NAND_PARAMS | cut -d":" -f6`
	UBI_VOLNAME_ROOT=`echo $NAND_PARAMS | cut -d":" -f7`
	[ -z ${mtd_dev_root} ] || [ -z ${UBI_DEV_ROOT} ] || [ -z ${UBI_VOLNAME_ROOT} ] && return
	ubi_format ${mtd_dev_root}
	ubi_attach ${mtd_dev_root} ${UBI_DEV_ROOT}
	ubi_mkvol ${UBI_DEV_ROOT} ${UBI_VOLNAME_ROOT}
	MTD_DEV_DTB=`echo $NAND_PARAMS | cut -d":" -f1`
	[ -z $MTD_DEV_DTB ] && return
	flash_erase ${MTD_DEV_DTB} 0 0
}

ubi_format() {
	announce "$FUNCNAME [ $@ ]"
	dev=$1
	[ -z $dev ] && return
	mtd="/dev/mtd"${dev}
	${UBIFORAMT} --yes ${mtd} 1>&- 2>&-
}

ubi_mkvol() {
	announce "$FUNCNAME [ $@ ]"
	ubi=$1; name=$2
	[ -z $ubi ] || [ -z $name ] && return
	ubi='/dev/ubi'${ubi}
	${UBIMKVOL} ${ubi} -m -N ${name} 1>&- 2>&-
}
