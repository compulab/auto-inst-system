#!/bin/bash

common=$(dirname $BASH_SOURCE)/common.sh
[ -f ${common} ] && . ${common}

ibootscr=bootscr.in
obootscr=bootscr.img
cat platform/${platform}/*.scr common/*.scr > ${ibootscr}
mkimage -C none -O Linux -A arm -T script -d ${ibootscr} ${obootscr}
# clean up
[ -f ${ibootscr} ] && rm ${ibootscr}
