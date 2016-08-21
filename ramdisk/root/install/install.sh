#!/bin/bash

cat << eom
	#     #
	#  #  #    ##    #####   #    #     #    #    #   ####
	#  #  #   #  #   #    #  ##   #     #    ##   #  #    #
	#  #  #  #    #  #    #  # #  #     #    # #  #  #
	#  #  #  ######  #####   #  # #     #    #  # #  #  ###
	#  #  #  #    #  #   #   #   ##     #    #   ##  #    #
	 ## ##   #    #  #    #  #    #     #    #    #   ####

	Running $BASH_SOURCE from the ramdisk
	Install the media that contains /$(basename $BASH_SOURCE)
eom
