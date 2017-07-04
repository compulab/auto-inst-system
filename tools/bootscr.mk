#!/bin/bash

common=$(dirname $BASH_SOURCE)/common.sh
[ -f ${common} ] && . ${common}

ibootscr=bootscr.in
obootscr=boot.scr.${platform}
cat platform/${platform}/bootscr/bootscr.source common/bootscr/bootscr.source > ${ibootscr}
mkimage -C none -O Linux -A arm -T script -d ${ibootscr} ${obootscr}
# clean up
[ -f ${ibootscr} ] && rm ${ibootscr}
