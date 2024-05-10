#!/bin/bash

# Pfad zur JSON-Datei
JSON_FILE="mounts.json"

# Überprüfen Sie, ob die JSON-Datei existiert
if [ ! -f "$JSON_FILE" ]; then
    echo "Die JSON-Datei $JSON_FILE existiert nicht."
    exit 1
fi

# Lese die JSON-Datei und mounte jedes NFS-Share
jq -c '.[]' $JSON_FILE | while read i; do
    NFS_SERVER=$(echo $i | jq -r '.NFS_SERVER')
    NFS_EXPORT=$(echo $i | jq -r '.NFS_EXPORT')
    NFS_OPTIONS=$(echo $i | jq -r '.NFS_OPTIONS')
    LOCAL_NFS_MOUNT=$(echo $i | jq -r '.LOCAL_NFS_MOUNT')

    # Erstelle das lokale Mount-Verzeichnis, falls es nicht existiert
    mkdir -p $LOCAL_NFS_MOUNT

    # Mounte das NFS-Share
    mount -t nfs -o $NFS_OPTIONS $NFS_SERVER:$NFS_EXPORT $LOCAL_NFS_MOUNT
done