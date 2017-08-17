#!/bin/bash

MPOINT=/mnt/install
INSTALL_EXT2=${MPOINT}/install.ext2

#############################################################################
# void warning_exit(int *exit_code) - Generate warning message and exit
# exit_code - script exit code
function warning_exit() {

cat << eom
        #     #
        #  #  #    ##    #####   #    #     #    #    #   ####
        #  #  #   #  #   #    #  ##   #     #    ##   #  #    #
        #  #  #  #    #  #    #  # #  #     #    # #  #  #
        #  #  #  ######  #####   #  # #     #    #  # #  #  ###
        #  #  #  #    #  #   #   #   ##     #    #   ##  #    #
         ## ##   #    #  #    #  #    #     #    #    #   ####

	Automatic installation files are missing or invalid, 
        Install the media that contains the automatic installation files.
eom

exit $1

}

################################### Main ####################################

if [ ! -f ${INSTALL_EXT2} ]; then
	warning_exit 1
fi

mount -o loop ${INSTALL_EXT2} ${MPOINT}
if [ $? -ne 0 ]; then
	 warning_exit 2
fi

if [ ! -x ${MPOINT}/install.sh ]; then
         warning_exit 3
fi

${MPOINT}/install.sh

umount -l ${MPOINT}

exit 0
