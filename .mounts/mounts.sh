#!/bin/bash

# This script mounts NFS directories defined in the .conf file

# Path variables from .conf file
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/.conf"

# The .conf file should be located in the $USER_HOME/.mounts directory
# 1. checks if nfs-common is installed
# 2. checks if the directories are already mounted
#       if not, it executes the mount command from the .conf file
# 3. logs the output to $USER_HOME/.mounts/mounts.log

# Check if nfs-common is installed
if ! dpkg -s nfs-common >/dev/null 2>&1; then
    echo "Fehler: nfs-common ist nicht installiert." | tee -a $LOGFILE
    exit 1
fi

# function to check if a directory is already mounted
check_mounted() {
    local dir="$1"

    # Check if the directory is a mount point
    if mountpoint -q "$dir"; then
        echo "Das Verzeichnis $dir ist bereits gemountet." | tee -a $LOGFILE
        return 0
    else
        echo "Das Verzeichnis $dir ist nicht gemountet." | tee -a $LOGFILE
        return 1
    fi
}

# Function that reads the .conf file and executes the mount commands
# calls check_mounted to check if the directory is already mounted
function mount_nfs() {
    # reads the .conf file and executes the mount commands
    while read -r line; do
        # ignore comments and empty lines
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue

        # validate the mount command
        if [[ "$line" =~ ^mount ]]; then
            # extract the mount command from the line
            dir=$(echo $line | awk '{print $3}')

            # checks if the directory is already mounted
            if check_mounted $dir; then
                echo "Überspringe das Mounten von $dir, da es bereits gemountet ist." | tee -a $LOGFILE
                continue
            fi

            # execute the mount command
            echo "Ausführung des Befehls: $line" | tee -a $LOGFILE
            eval $line 2>>$LOGFILE
            if [ $? -ne 0 ]; then
                echo "Error executing command: $line" | tee -a $LOGFILE
                exit 1
            fi
        else
            echo "Command not allowed: $line" | tee -a $LOGFILE
            exit 1
        fi
    done < "$USER_HOME/.mounts/.conf"
}

# call the function to mount the NFS directories
mount_nfs

