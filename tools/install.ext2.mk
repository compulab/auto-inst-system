#!/bin/bash

common=$(dirname $BASH_SOURCE)/common.sh
[ -f ${common} ] && . ${common}

installer=install.ext2.${platform}
size_inm=1
mpoint=$(mktemp -d)
dd if=/dev/zero of=${installer} count=${size_inm} bs=1M
echo "y" | mkfs.ext2 -L installer.${platform} ${installer}
sudo mount -o loop ${installer} ${mpoint}
if  [ $? -eq 0 ];then
	for src in common platform/${platform};do
		sudo cp -v ${src}/ext2.loop/* ${mpoint} 2>/dev/null
	done
	sudo umount -l ${mpoint}
fi
rm -rf ${mpoint}
