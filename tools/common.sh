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

if [ -z ${platform} ];then
select_string=$(ls platform/; echo "<<")
PS3="select a platform > "
select i in $select_string; do
	case $i in
		"<<")
		exit
		break
		;;
		*)
		platform=$i
		break
		;;
	esac
done
else
if [ ! -d platform/${platform} ];then
cat << eom
	Invalid platform ${platform}
eom
	exit 1
fi
fi
