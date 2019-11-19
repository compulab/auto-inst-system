#!/bin/sh
#
# Automatic installation system
#
# Copyright (C) 2019 CompuLab, Ltd.
# Author: Ilya Ledvich <ilya@compulab.co.il>
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

. "${SCR_PATH}/functions.sh"

#set -x
#extra_mounts=`grep extra_mount= ${CONFIG_FILE} | cut -d= -f2-`

##### Main #####
announce "Unmounting extra images"

for e in ${extra_mounts[@]}; do
    umount ${e}
done

#set +x

return 0
