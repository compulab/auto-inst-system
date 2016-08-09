#!/bin/sh

##### Constants #####
PRINTK_NONE="1 1 1 1"
printk_config=$(cat /proc/sys/kernel/printk)

SOURCE_MOUNT_PATH=/media/source

. "/etc/init.d/board_params.sh"
. "/etc/init.d/functions.sh"

## Sanicty Check ##
[ $(basename $BASH_SOURCE) == $(basename $0) ] && EXIT="exit" || EXIT="return"
[ -z ${SOURCE_MEDIA} ] && ${EXIT} 3

title " Mount Source ${SOURCE_MEDIA} "
mount_source
