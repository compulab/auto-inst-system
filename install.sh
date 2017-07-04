#!/bin/bash

INSTALL_EXT2=$(dirname $BASH_SOURCE)/install.ext2
MPOINT=/root/install

[ -f ${INSTALL_EXT2} ] || exit 1

mount -o loop ${INSTALL_EXT2} ${MPOINT}
[ $? -ne 0 ] && exit 2

[ -x ${MPOINT}/install.sh ] && ${MPOINT}/install.sh

umount -l ${MPOINT}

exit 0
