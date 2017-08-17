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

#############################################################################
# int wait_on_pid(int pid)
#
# wait command wrapper for ATP.
# Returns wait command return value
wait_on_pid() {
        local pid=$1

        while [ -e /proc/$pid ] ; do
                echo -n "."
                sleep 1
        done

        echo ""
        wait $pid

        return $?
}

#############################################################################
# int cmd_progr(char *cmd, ...)
#
# Any command wrapper with progress indication
# Returns 0 in case of success, 1 otherwise
cmd_progr() {
        local cmd=$1
        shift;

        $cmd $* &> /dev/null & pid=$!

        wait_on_pid $pid

        return $?
}
