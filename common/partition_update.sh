NANDWRITE=$(which nandwrite &>/dev/null && which nandwrite || echo -n 'echo nandwrite')

copy_kernel_files() {
	announce "Copying kernel files"
	if [ ! -z ${NAND_PARAMS} ];then
		copy_kernel_files_nand
		return
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
	announce "$FUNCNAME [ $@ ]"
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
	MTD_OFFS_KERNEL=`echo $NAND_PARAMS | cut -d":" -f4`
	[ -z $MTD_DEV_KERNEL ] || [ -z $MTD_OFFS_KERNEL ] && return
	file='zImage*'
	stat ${SOURCE_MOUNT_PATH}/${file} &>/dev/null
	[ $? -ne 0 ] && return
	nand_write ${MTD_DEV_KERNEL} ${SOURCE_MOUNT_PATH}/${file} $MTD_OFFS_KERNEL || return $?
	MTD_OFFS_DTB=`echo $NAND_PARAMS | cut -d":" -f2`
	[ -z $MTD_DEV_DTB ] || [ -z $MTD_OFFS_DTB ] && return
	files=`ls ${SOURCE_MOUNT_PATH}/*.dtb`
	for file in ${files};do
		[ ${file##*/} == "ramdisk.dtb" ] && continue
		stat ${file} &>/dev/null
		[ $? -ne 0 ] && continue
		nand_write ${MTD_DEV_DTB} ${file} $MTD_OFFS_DTB || return $?
	done
}
