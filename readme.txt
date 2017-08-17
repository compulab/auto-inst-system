Installation SD card For any modules
**************************************

RAM disk file system
---------------------
ramdisk is ready to run on any arm platform.
requires no changes at all.
Latest working ramdisk is found in the repository as ramdisk.img

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

zImage* - target kernel image
*.dtb - target device tree files

Tools
--------------------------
tools/install.ext2.mk - ext2 image creator
	run it from the current direcory
	select a desire platform (or export the platform environment variable)
	result: install.ext2.${platform} in the current directory
	copy the file into the root directory
	of an installation SD card.
	Sample run:
	export platform=imx6
	./tools/install.ext2.mk
	cp install.ext2.imx6 <sd-installer-mount-point>/install.ext2
	

tools/bootscr.mk - bootscr.img creator
	run it from the current direcory
	select a desire platform (or export the platform environment variable)
	result: boot.scr.${platform} in the current directory
	copy the file into the root directory
	of an installation SD card.
	Sample run:
	export platform=imx6
	./tools/bootscr.mk
	cp boot.scr.imx6 <sd-installer-mount-point>/boot.scr

Installation instructions
---------------------------
* Obtain an SD card. Any commercially available SD card of 1GB (or larger) may be used.
* Create a first partition on it. The partition can be formatted either ext2/3/4 or FAT file system.
Note: usually a brand new SD cards are already formatted and should not need re-partitioning and re-formatting.
* Copy all files, described in the "Installation SD card files" section, to the first partition on the installation media (SD card).
* Plug the installation media in the target device.
* Turn on the target device.
* The system will boot from the installation media and start the automatic installation procedure.

Terminal capture of example installation:
===CompuLab Automatic Installation System 0.1.0 (Aug 15 2017)===
Press any key to cancel installation   0
=== Mount Source /dev/mmcblk1p1 ===
* mount_source [  ]
===Installing OS===
* Updating partitions
* Formatting partitions
* mount_destination [  ]
* Copying kernel files
* Extracting user space rootfs.tar.bz2
 393MiB 0:04:01 [1.63MiB/s] [================================>] 100%            
* unmount_destination [  ]
=== Unmount Source /dev/mmcblk1p1 ===
* unmount_source [  ]
Please remove installation SD card ...
Press any key to cancel restart   0

