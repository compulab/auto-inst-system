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

NORMAL="\033[0m"
GREEN="\033[32;1m"
RED="\033[31;1m"
BLUE="\033[34;1m"

title() {
	echo -e "${GREEN}===${1}===${NORMAL}"
}

announce() {
	echo -e "${GREEN}* ${NORMAL}${@}"
}

debug_msg() {
	[ -z ${DEBUG_INSTALL} ] && return
	echo -e "${BLUE}* ${NORMAL}${@}"
}

function err_msg() {
	echo -e "${RED}${@}${NORMAL}"
}

