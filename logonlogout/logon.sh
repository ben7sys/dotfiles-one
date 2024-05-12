#!/bin/bash
 
# Definiere die NFS-Shares, ihre Server und ihre Mount-Punkte
declare -A mounts=(
    ["192.168.77.151:tank/share"]="/mnt/nfs/zmbfs/share"
    ["192.168.77.151:tank/manage"]="/mnt/nfs/zmbfs/manage"
    ["192.168.77.151:tank/exports"]="/mnt/nfs/zmbfs/exports"
)

# Gehe durch jedes NFS-Share
for server_share in "${!mounts[@]}"; do
    mount_point="${mounts[$server_share]}"

    # Überprüfe, ob das Share bereits gemountet ist
    if grep -qs "$mount_point" /proc/mounts; then
        continue
    fi

    # Versuche, das Share zu mounten und überprüfe, ob der Befehl erfolgreich war
    if timeout 5 mount -t nfs -o hard,nolock "$server_share" "$mount_point"; then
        echo "$server_share wurde erfolgreich auf $mount_point gemountet."
    else
        if [ $? -eq 124 ]; then
            echo "Timeout beim Mounten von $server_share auf $mount_point."
        else
            echo "Fehler beim Mounten von $server_share auf $mount_point."
        fi
    fi
done