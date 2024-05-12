#!/bin/bash

# Definiere die Mount-Punkte
mount_points=(
    "/mnt/nfs/zmbfs/share"
    "/mnt/nfs/zmbfs/manage"
    "/mnt/nfs/zmbfs/exports"
)

# Gehe durch jeden Mount-Punkt
for mount_point in "${mount_points[@]}"; do
    # Überprüfe, ob das Share bereits unmountet ist
    if ! grep -qs "$mount_point" /proc/mounts; then
        echo "$mount_point ist bereits unmountet."
        continue
    fi

    # Versuche, das Share zu unmounten und überprüfe, ob der Befehl erfolgreich war
    if timeout 5 umount "$mount_point"; then
        echo "$mount_point wurde erfolgreich unmountet."
    else
        if [ $? -eq 124 ]; then
            echo "Timeout beim Unmounten von $mount_point."
        else
            echo "Fehler beim Unmounten von $mount_point."
        fi
    fi
done