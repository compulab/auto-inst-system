#!/bin/sh

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
# Constants
AUTO_INSTALL="auto_install"

# Get kernel command line
k_command=$(cat /proc/cmdline)
# Exit if automatic installation is not needed
if [ ! -z "${k_command##*$AUTO_INSTALL*}" ] ;then
	exit 0
fi

count_down "Press any key to cancel installation" 5
if [ $? -eq 0 ]
then
        echo "Installation aborted"
        exit 0;
fi

# Start all init scripts in /etc/init.d
# executing them in numerical order.
for i in /etc/init.d/S??*.sh ;do
	# Ignore dangling symlinks (if any).
	[ ! -f "$i" ] && continue
	. $i
done

echo "Please remove installation SD card ..."
count_down "Press any key to cancel restart" 5
if [ $? -eq 0 ]
then
        echo "Restart aborted"
        exit 0;
fi
# Rebooting system
reboot
