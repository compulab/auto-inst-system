#!/bin/bash
#
# Automatic installation system
#
# Copyright (C) 2017 CompuLab, Ltd.
# Author: Uri Mashiach <uri.mashiach@compulab.co.il>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or later
# version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

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
		sudo cp -v ${src}/* ${mpoint} 2>/dev/null
	done
	sudo umount -l ${mpoint}
fi
rm -rf ${mpoint}
