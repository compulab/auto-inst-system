#!/bin/sh
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

##### Constants #####
PRINTK_NONE="1 1 1 1"
printk_config=$(cat /proc/sys/kernel/printk)
SCR_PATH=$(dirname $BASH_SOURCE)

SOURCE_MOUNT_PATH=/media/source

. "${SCR_PATH}/board_params.sh"
. "${SCR_PATH}/functions.sh"

## Sanicty Check ##
[ $(basename $BASH_SOURCE) == $(basename $0) ] && EXIT="exit" || EXIT="return"
[ -z ${SOURCE_MEDIA} ] && ${EXIT} 3

title " Mount Source ${SOURCE_MEDIA} "
mount_source || return $?
