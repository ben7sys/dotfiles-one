#!/bin/bash

# ===================================
# Mount Synology Shares Script
# ===================================
#
# Description:
#   This script mounts and unmounts Synology NAS shares using CIFS and NFS protocols.
#
# Usage:
#   ./mount-syno.sh             - Mount all shares
#   ./mount-syno.sh -u          - Unmount all shares
#   ./mount-syno.sh -u <share>  - Unmount a specific share
#
# Dependencies:
#   - cifs-utils (for CIFS mounts)
#   - nfs-common (for NFS mounts)
#
# Configuration:
#   - CIFS shares are defined in the CIFS_SHARES associative array
#   - NFS share is defined in NFS_SHARE variable
#   - Credentials for CIFS are stored in /home/sieben/.smbcred
#
# Features:
#   - Mounts multiple CIFS shares and one NFS share
#   - Checks if shares are already mounted before attempting to mount
#   - Provides options to unmount all shares or a specific share
#   - Creates mount points if they don't exist
#
# Author: [ben7sys]
# Created: [2024-09-15]
# Last Modified: [2024-09-15]
#
# ===================================

# Define variables
CREDENTIALS_FILE="/home/sieben/.smbcred"
CIFS_MOUNT_OPTIONS="uid=1000,gid=1000,credentials=${CREDENTIALS_FILE},file_mode=0755,dir_mode=0755"
NFS_MOUNT_OPTIONS="noauto"

# Define shares to mount
declare -A CIFS_SHARES=(
    ["//192.168.77.77/archiv"]="/syno/archiv"
    ["//192.168.77.77/backup"]="/syno/backup"
    ["//192.168.77.77/cloudsync"]="/syno/cloudsync"
    ["//192.168.77.77/downloads"]="/syno/downloads"
    ["//192.168.77.77/games"]="/syno/games"
    ["//192.168.77.77/home"]="/syno/home"
    ["//192.168.77.77/music"]="/syno/music"
    ["//192.168.77.77/share"]="/syno/share"
    ["//192.168.77.77/software"]="/syno/software"
    ["//192.168.77.77/video"]="/syno/video"
)

# Define NFS share
NFS_SHARE="192.168.77.77:/volume1/sieben"
NFS_MOUNT_POINT="/syno/sieben"

# Function to check if a directory is already mounted
is_mounted() {
    mountpoint -q "$1"
}

# Function to mount a CIFS share
mount_cifs_share() {
    local share_path="$1"
    local mount_point="$2"

    # Check if the mount point exists, if not create it
    if [ ! -d "${mount_point}" ]; then
        sudo mkdir -p "${mount_point}"
    fi

    # Check if the directory is already mounted
    if is_mounted "${mount_point}"; then
        echo "${mount_point} is already mounted"
        return
    fi

    # Attempt to mount the share
    sudo mount -t cifs "${share_path}" "${mount_point}" -o "${CIFS_MOUNT_OPTIONS}"

    # Check if the mount was successful
    if [ $? -eq 0 ]; then
        echo "Successfully mounted ${share_path} to ${mount_point}"
    else
        echo "Failed to mount ${share_path} to ${mount_point}"
    fi
}

# Function to mount the NFS share
mount_nfs_share() {
    # Check if the mount point exists, if not create it
    if [ ! -d "${NFS_MOUNT_POINT}" ]; then
        sudo mkdir -p "${NFS_MOUNT_POINT}"
    fi

    # Check if the directory is already mounted
    if is_mounted "${NFS_MOUNT_POINT}"; then
        echo "${NFS_MOUNT_POINT} is already mounted"
        return
    fi

    # Attempt to mount the NFS share
    sudo mount -t nfs "${NFS_SHARE}" "${NFS_MOUNT_POINT}" -o "${NFS_MOUNT_OPTIONS}"

    # Check if the mount was successful
    if [ $? -eq 0 ]; then
        echo "Successfully mounted ${NFS_SHARE} to ${NFS_MOUNT_POINT}"
    else
        echo "Failed to mount ${NFS_SHARE} to ${NFS_MOUNT_POINT}"
    fi
}

# Function to unmount a specific share
unmount_specific_share() {
    local share_name="$1"
    local mount_point=""

    # Check if it's an NFS share
    if [ "$share_name" = "sieben" ]; then
        mount_point="${NFS_MOUNT_POINT}"
    else
        # Find the corresponding mount point for CIFS shares
        for path in "${!CIFS_SHARES[@]}"; do
            if [[ "${CIFS_SHARES[$path]}" == *"$share_name"* ]]; then
                mount_point="${CIFS_SHARES[$path]}"
                break
            fi
        done
    fi

    if [ -n "$mount_point" ]; then
        unmount_share "$mount_point"
    else
        echo "Share '$share_name' nicht gefunden"
    fi
}

# Function to unmount a share
unmount_share() {
    local mount_point="$1"

    if is_mounted "${mount_point}"; then
        sudo umount "${mount_point}"
        if [ $? -eq 0 ]; then
            echo "Successfully unmounted ${mount_point}"
        else
            echo "Failed to unmount ${mount_point}"
        fi
    else
        echo "${mount_point} is not mounted"
    fi
}

# Function to unmount all shares
unmount_all_shares() {
    for mount_point in "${CIFS_SHARES[@]}"; do
        unmount_share "${mount_point}"
    done
    unmount_share "${NFS_MOUNT_POINT}"
}

# Parse command line arguments
if [ "$1" = "-u" ] || [ "$1" = "--unmount" ]; then
    if [ -n "$2" ]; then
        # Unmount specific share
        unmount_specific_share "$2"
    else
        # Unmount all shares
        unmount_all_shares
    fi
    exit 0
fi

# Mount all defined CIFS shares
for share_path in "${!CIFS_SHARES[@]}"; do
    mount_cifs_share "$share_path" "${CIFS_SHARES[$share_path]}"
done

# Mount the NFS share
mount_nfs_share
