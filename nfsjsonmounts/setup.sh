#!/bin/bash

JSON_FILE="mounts.json"
LOG_FILE="mounts.log"

# Exit if JSON file does not exist
if [ ! -f "$JSON_FILE" ]; then
    echo -e "\033[0;31mDie JSON-Datei $JSON_FILE existiert nicht.\033[0m" | tee -a $LOG_FILE
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
        echo -e "\033[0;33mDas Verzeichnis $local_nfs_mount ist gemountet.\033[0m" | tee -a $LOG_FILE
        read -p "Möchten Sie es unmounten? (y/n): " response < /dev/tty
        if [[ "$response" == "y" ]]; then
            if umount "$local_nfs_mount"; then
                echo -e "\033[0;32mUnmount von $local_nfs_mount erfolgreich.\033[0m" | tee -a $LOG_FILE
            else
                echo "Unmount von $local_nfs_mount fehlgeschlagen." | tee -a $LOG_FILE
            fi
        fi
    else
        echo -e "\033[0;33mDas Verzeichnis $local_nfs_mount ist nicht gemountet.\033[0m" | tee -a $LOG_FILE
        read -p "Möchten Sie es mounten? (y/n): " response < /dev/tty
        if [[ "$response" == "y" ]]; then
            [[ ! -d "$local_nfs_mount" ]] && mkdir -p "$local_nfs_mount"
            if mount -t nfs -o $nfs_options $nfs_server:$nfs_export $local_nfs_mount; then
                echo -e "\033[0;32mMount von $nfs_server:$nfs_export auf $local_nfs_mount erfolgreich.\033[0m" | tee -a $LOG_FILE
            else
                echo "Mount von $nfs_server:$nfs_export auf $local_nfs_mount fehlgeschlagen." | tee -a $LOG_FILE
            fi
        fi
    fi
}

# Read and process each NFS share
echo "---------------------------------------------------------"
echo " NFS JSON MOUNT TOOL"
echo " Start: $(date)"
echo "---------------------------------------------------------"

jq -c '.[]' $JSON_FILE | while IFS= read -r i; do
    NFS_SERVER=$(echo "$i" | jq -r '.NFS_SERVER')
    NFS_EXPORT=$(echo "$i" | jq -r '.NFS_EXPORT')
    NFS_OPTIONS=$(echo "$i" | jq -r '.NFS_OPTIONS')
    LOCAL_NFS_MOUNT=$(echo "$i" | jq -r '.LOCAL_NFS_MOUNT')

    echo ""
    #echo "Beginne Verarbeitung für: $NFS_SERVER:$NFS_EXPORT"
    handle_mount "$NFS_SERVER" "$NFS_EXPORT" "$NFS_OPTIONS" "$LOCAL_NFS_MOUNT"
    #echo "Beendete Verarbeitung für: $NFS_SERVER:$NFS_EXPORT"
    echo "---------------------------------------------------------"
done

echo "| Ausführung beendet am: $(date)"
echo "---------------------------------------------------------"
