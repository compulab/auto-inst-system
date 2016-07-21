#!/bin/bash -xv

echo "Running $BASH_SOURCE with $@"

BOARD_PARAM=/etc/init.d/board_params.sh
DIR=$(dirname $BASH_SOURCE)

[ ! -f ${BOARD_PARAM} ] && exit 1
. ${BOARD_PARAM}

[ -z $DESTINATION_KERNEL_MEDIA ] && exit 2

boot_scr=${DIR}/$([[ ${DESTINATION_KERNEL_MEDIA} =~ "mmc" ]] &&  echo "boot.mmc.scr" || echo "boot.sata.scr" )

stat $boot_scr &>/dev/null
[ $? -ne 0 ] && exit 3

TMP_DIR=$(mktemp -du)
mkdir -p ${TMP_DIR} && mount ${DESTINATION_KERNEL_MEDIA} ${TMP_DIR}
cp -v  $boot_scr ${TMP_DIR}/boot.scr 
umount ${TMP_DIR}
rm -rf ${TMP_DIR}
