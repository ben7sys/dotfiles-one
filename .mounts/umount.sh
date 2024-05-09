#!/bin/bash
grep '^mount ' /home/sieben/.mounts/.conf | while read line
do
    # Extrahieren Sie den Mount-Punkt aus der Zeile
    mount_point=$(echo $line | cut -d ' ' -f 5)

    # Überprüfen Sie, ob der Mount-Punkt gültig und aktuell gemountet ist
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