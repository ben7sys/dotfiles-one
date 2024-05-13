#!/bin/bash

handle_mount() {
    local nfs_server=$1
    local nfs_export=$2
    local nfs_options=$3
    local local_nfs_mount=$4

    echo "Verarbeite $nfs_server:$nfs_export auf $local_nfs_mount mit Optionen $nfs_options"

    if grep -qs "$local_nfs_mount" /proc/mounts; then
        echo "$local_nfs_mount ist bereits gemountet."
    else
        echo "$local_nfs_mount ist nicht gemountet."
    fi
}

# Testaufruf
handle_mount "192.168.77.151" "tank/manage" "hard,nolock" "/mnt/nfs/zmbfs/manage"
