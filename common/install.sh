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

# Constants
AUTO_INSTALL_VERSION="2.0.0"
AUTO_INSTALL_VERSION_DATE="Mar 07 2018"
AUTO_INSTALL_BANNER="CompuLab Automatic Installation System ${AUTO_INSTALL_VERSION} (${AUTO_INSTALL_VERSION_DATE})"
AUTO_INSTALL="auto_install"
MPOINT=$(dirname $BASH_SOURCE)

# Includes
. "${MPOINT}/messages.sh"

##### Functions #####
count_down()
{
        local ret_code=1

        printf "$1    "
        for i in $(seq $2 -1 0)
        do
                printf "\b\b\b%3d" $i
                read -s -n 1 -t 1 key
                if [ $? -eq 0 ] ; then
                        ret_code=0
                        break;
                fi;
        done
        printf "\n"
        return $ret_code
}

##### Main #####
main()
{
	# Display version
	title "${AUTO_INSTALL_BANNER}"

	# Get kernel command line
	k_command=$(cat /proc/cmdline)
	# Exit if automatic installation is not needed
	if [ ! -z "${k_command##*$AUTO_INSTALL*}" ] ;then
		exit 0
	fi

	count_down "Press any key to cancel installation" 5
	if [ $? -eq 0 ]; then
		echo "Installation aborted"
		exit 0;
	fi

	# Start all init scripts in /mnt/install
	# executing them in numerical order.
	for i in ${MPOINT}/[0-9][0-9]*.sh; do
		# Ignore dangling symlinks (if any).
		[ ! -f "$i" ] && continue
		. $i
		[ $? -ne 0 ] && exit 1
	done

	echo "Please remove installation SD card ..."
	count_down "Press any key to cancel restart" 5
	if [ $? -eq 0 ]; then
		echo "Restart aborted"
		exit 0;
	fi
	# Rebooting system
	reboot
}

main
