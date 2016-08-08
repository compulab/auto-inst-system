#!/bin/bash

echo "Running $BASH_SOURCE with $@"

BOARD_PARAM=/etc/init.d/board_params.sh
ROOTFS_FILE_PATT=*.update.tar.bz2

[ ! -f ${BOARD_PARAM} ] && exit 1
. ${BOARD_PARAM}

[ -z $DESTINATION_MEDIA ] && exit 2
[ -z $SOURCE_MEDIA ] && exit 3

part_pref=$([[ ${DESTINATION_MEDIA} =~ "mmc" ]] &&  echo -n "p")

ROOT=${DESTINATION_MEDIA}${part_pref}2
BOOT=${DESTINATION_MEDIA}${part_pref}1

SRC_DIR=$(mktemp -du)
DST_DIR=$(mktemp -du)
OUT_FILE=${DST_DIR}/_out_file

mkdir -p ${SRC_DIR} && mount ${SOURCE_MEDIA} ${SRC_DIR}
ls ${SRC_DIR}/${ROOTFS_FILE_PATT} &>/dev/null
if [ $? -eq 0 ];then
	mkdir -p ${DST_DIR} && mount ${ROOT} ${DST_DIR}
	mount ${BOOT} ${DST_DIR}/boot
	for _file in ${SRC_DIR}/${ROOTFS_FILE_PATT};do
	echo 'Processing file '$(basename $_file)
	which pv &>/dev/null
	if [ $? -eq 0 ];then
		pv ${_file} | tar --numeric-owner -xpjf - -C ${DST_DIR} > /dev/null && sync
	else
		tar --numeric-owner -xpjf ${_file} -C ${DST_DIR} > /dev/null && sync
	fi
	done
	umount -l ${DST_DIR}/boot
	umount -l ${DST_DIR}
	rm -rf ${DST_DIR}
else
	echo "Nothing to update ..."
fi

umount -l ${SRC_DIR}
rm -rf ${SRC_DIR}
