#!/bin/bash

platform=""
select_string=$(ls platform/; echo "<<")
PS3="select a platform > "
select i in $select_string; do
	case $i in
		"<<")
		exit
		break
		;;
		*)
		platform=$i
		break
		;;
	esac
done

installer=/tmp/install.ext2
size_inm=1
dd if=/dev/zero of=${installer} count=${size_inm} bs=1M
echo "y" | mkfs.ext2 -L installer.${platform} ${installer}
device=$(sudo losetup -sf ${installer})
[ $? -eq 0 ] || exit 1
sudo hdparm -z ${device}
sleep 0.5
mpoint=$(udisks --mount ${device} | awk '$0=$NF')
[ $? -eq 0 ] || exit 2
sudo cp -v common/*.sh platform/${platform}/*.sh ${mpoint}
udisks --unmount ${device}
sudo losetup -d ${device}
