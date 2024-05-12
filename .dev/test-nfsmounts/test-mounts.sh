#!/bin/bash

JSON_FILE="mounts.json"
LOG_FILE="mounts.log"

# Exit if JSON file does not exist
if [ ! -f "$JSON_FILE" ]; then
    echo "Die JSON-Datei $JSON_FILE existiert nicht." | tee -a $LOG_FILE
    exit 1
fi

# Install jq if not present
if ! command -v jq &> /dev/null; then
    sudo apt-get install -y jq
fi

# Function to handle mounting or unmounting
handle_mount() {
    local nfs_server=$1
    local nfs_export=$2
    local nfs_options=$3
    local local_nfs_mount=$4

    echo "Verarbeite $nfs_server:$nfs_export auf $local_nfs_mount mit Optionen $nfs_options" | tee -a $LOG_FILE

    if grep -qs "$local_nfs_mount" /proc/mounts; then
        read -p "Das Verzeichnis $local_nfs_mount ist gemountet. Möchten Sie es unmounten? (y/n): " response < /dev/tty
        [[ "$response" == "y" ]] && umount "$local_nfs_mount" && echo "Unmount erfolgreich." | tee -a $LOG_FILE || echo "Unmount fehlgeschlagen." | tee -a $LOG_FILE
    else
        read -p "Das Verzeichnis $local_nfs_mount ist nicht gemountet. Möchten Sie es mounten? (y/n): " response < /dev/tty
        if [[ "$response" == "y" ]]; then
            [[ ! -d "$local_nfs_mount" ]] && mkdir -p "$local_nfs_mount"
            mount -t nfs -o $nfs_options $nfs_server:$nfs_export $local_nfs_mount && echo "Mount erfolgreich." | tee -a $LOG_FILE || echo "Mount fehlgeschlagen." | tee -a $LOG_FILE
        fi
    fi
}

# Read and process each NFS share
jq -c '.[]' $JSON_FILE | while IFS= read -r i; do
    NFS_SERVER=$(echo "$i" | jq -r '.NFS_SERVER')
    NFS_EXPORT=$(echo "$i" | jq -r '.NFS_EXPORT')
    NFS_OPTIONS=$(echo "$i" | jq -r '.NFS_OPTIONS')
    LOCAL_NFS_MOUNT=$(echo "$i" | jq -r '.LOCAL_NFS_MOUNT')

    echo "Beginne Verarbeitung für: $NFS_SERVER:$NFS_EXPORT"
    handle_mount "$NFS_SERVER" "$NFS_EXPORT" "$NFS_OPTIONS" "$LOCAL_NFS_MOUNT"
    echo "Beendete Verarbeitung für: $NFS_SERVER:$NFS_EXPORT"
done
