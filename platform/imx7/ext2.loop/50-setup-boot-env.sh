#!/bin/sh

PRINTK_NONE="1 1 1 1"
SCR_PATH=/root/install
#set -xv

##### External Scripts #####
. "${SCR_PATH}/functions.sh"

ENV_DEVICE_NUM=1
ENV_DEVICE="/dev/mtd"$ENV_DEVICE_NUM
ENV_TMP_SOURCE=/tmp/boot_env.source
ENV_IMAGE=/tmp/boot_env.image
ENV_SIZE=8192
FW_ENV_CONFIG=/etc/fw_env.config

# Prepare bootloader environment
title " Setup bootloader environment "
# Copy the template
cat > $ENV_TMP_SOURCE << EOF
autoload=off
baudrate=115200
board_name=CL-SOM-iMX7
bootargs=console=ttymxc0,115200 root=/dev/mmcblk2p2 rootwait rw
bootcmd=run loadimage; run loadfdt; run set_display; bootz \${loadaddr} - \${fdt_addr}
bootdelay=3
console=ttymxc0
ethact=FEC0
ethprime=FEC
fdt_addr=0x83000000
fdt_file=imx7d-sbc-imx7.dtb
fdt_high=0xffffffff
image=zImage-cl-som-imx7
initrd_high=0xffffffff
loadaddr=0x80800000
loadfdt=load mmc \${mmcdev}:\${mmcpart} \${fdt_addr} \${fdt_file}
loadimage=load mmc \${mmcdev}:\${mmcpart} \${loadaddr} \${image}
mmcblk=2
mmcdev=1
mmcpart=1
mmcroot=/dev/mmcblk2p2 rootwait rw
set_display=fdt addr \${fdt_addr}; fdt rm lcdif/display/display-timings/lcd
stderr=serial
stdin=serial
stdout=serial
EOF

# Prepare config file for fw_printenv utility
cat > $FW_ENV_CONFIG << EOF
# Configuration file for fw_(printenv/saveenv) utility for
# CompuLab cl-som-imx7

# MTD name	Device offset	Env. size	Flash sector size
/dev/mtd1	0x0000		0x2000		0x2000
EOF

# Expand the template with board specific variables
fw_printenv ethaddr >> $ENV_TMP_SOURCE > /dev/null 2>&1
fw_printenv serialpn >> $ENV_TMP_SOURCE > /dev/null 2>&1
fw_printenv serial# >> $ENV_TMP_SOURCE > /dev/null 2>&1

# Generate a ready to be flashed environment image
mkenvimage -s $ENV_SIZE -o $ENV_IMAGE $ENV_TMP_SOURCE

# Erase environment partition
flash_erase $ENV_DEVICE_NUM 0 0 > /dev/null 2>&1

# Flash the environment image
dd if=$ENV_IMAGE of=$ENV_DEVICE bs=1K > /dev/null 2>&1
