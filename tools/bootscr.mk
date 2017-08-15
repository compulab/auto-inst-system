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

ibootscr=bootscr.in
obootscr=boot.scr.${platform}
cat platform/${platform}/bootscr/bootscr.source common/bootscr/bootscr.source > ${ibootscr}
mkimage -C none -O Linux -A arm -T script -d ${ibootscr} ${obootscr}
# clean up
[ -f ${ibootscr} ] && rm ${ibootscr}
