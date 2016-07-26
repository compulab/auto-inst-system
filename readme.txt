Installation SD card For any modules
**************************************

RAM disk file system
---------------------
ramdisk is ready to run on any arm platform.
requires no changes at all.
ramdisk location is:
ssh:team@192.168.11.170:/home/val/Devel/tmp/release/installer/ramdisk.img
http://192.168.11.170/release/installer/ramdisk.img

Installation SD card files
--------------------------
bootscr.img - boot script image
ramdisk.img - RAM disk image
kernel.img - installation kernel image
ramdisk.dtb - installation device tree

rootfs.tar.bz2 - file system image
	if the file is not provided
	the S10-install exits with an error
	the main stript continues the script list execution

*.update.tar.bz2 - file system update image(s)
	if there are no files that match the pattern
	the S30-update exits with an error
	the main stript continues the script list execution

install.ext2   - etx2 image that contains all:
	common and platform specific installaton scripts.
install.sh     - ext2 image mounter

rootfs-update - file system update image
<module kernel> - module kernel image
<module DTB> - module device tree

Tools
--------------------------
tools/install.ext2.mk - ext2 image creator
	run it from the current direcory
	select a desire platform
	result: install.ext2 in the current directory
	copy the file into the root directory
	of an installation SD card.
	Sample run:
	./tools/install.ext2.mk
	

tools/bootscr.mk - bootscr.img creator
	run it from the current direcory
	select a desire platform
	result: bootscr.img in the current directory
	copy the file into the root directory
	of an installation SD card.
	Sample run:
	./tools/bootscr.mk
