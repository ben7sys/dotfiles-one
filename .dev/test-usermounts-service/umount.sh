#!/bin/bash

# This script unmounts NFS directories defined in the .conf file

# Path variables from .conf file
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/.conf"

# grep the mount commands from the .conf file and iterate over them
grep '^mount ' /home/sieben/.mounts/.conf | while read line
do
    # extract the mount point from the mount command
    mount_point=$(echo $line | cut -d ' ' -f 5)

    # check if the mount point is a valid directory and if it is mounted
    if [ -d "$mount_point" ] && mountpoint -q "$mount_point"; then
        /bin/umount $mount_point
        if [ $? -eq 0 ]; then
            echo "Unmounted $mount_point successfully."
        else
            echo "Failed to unmount $mount_point."
        fi
    else
        echo "$mount_point is not a valid mount point."
    fi
done