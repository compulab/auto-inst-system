Installation SD card For eMMC modules
**************************************

RAM disk file system
---------------------
The following files should be placed/updated in the RAM disk file system:
/etc/inittab - call to /etc/init.d/install_sd.sh was added
/etc/init.d/install_sd.sh - main installation script. Call S* installation scripts.
/etc/init.d/S10-install_mmc.sh - Create boot and rootfs partitions on the eMMC
                               - Copy kernel files
                               - Extract the root file system
/etc/init.d/S50-userspace-update.sh - Update file system

Installation SD card files
--------------------------
bootscr.img - boot script image
ramdisk.img - RAM disk image
kernel.img - installation kernel image
ramdisk.dtb - installation device tree
debian-armhf-image.tar.bz2 - file system image
rootfs-update - file system update image
<module kernel> - module kernel image
<module DTB> - module device tree
