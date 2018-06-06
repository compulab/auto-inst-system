#!/bin/bash

MPOINT=/mnt/install
MPOINT_SCRIPTS=/mnt/scripts
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

mount -ro loop ${INSTALL_EXT2} ${MPOINT_SCRIPTS}
if [ $? -ne 0 ]; then
	 warning_exit 2
fi

if [ ! -x ${MPOINT_SCRIPTS}/install.sh ]; then
         warning_exit 3
fi

${MPOINT_SCRIPTS}/install.sh

umount -l ${MPOINT_SCRIPTS}

exit 0
