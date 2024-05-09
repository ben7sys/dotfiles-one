#!/bin/bash

# Script for setting up service directories and files

# Anleitung:
# 1. Clone the dotfiles Git repository to $USER_HOME/dotfiles: git clone https://github.com/ben7sys/dotfiles.git
#    !! If a different path is used, the DOTFILES_DIR variable must be adjusted accordingly
# Path variables

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/.conf"

# Check if the variables are set correctly
echo
echo USER_HOME:         $USER_HOME
echo TARGET_DIRS:       $TARGET_DIRS
echo 
echo AUTOMATED VARIABLES:
echo SOURCE_DIR:        $SOURCE_DIR
echo DOTFILES_DIR:      $DOTFILES_DIR
echo LOGFILE_MOUNTS:    $LOGFILE_MOUNTS
echo

# Ask user: Are the variables correct?
read -p "Are the variables correct? (y/n) " -n 1 -r

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please edit the .conf file and run the script again."
    exit 1
fi


# Description:
# This script links the directories .config, .mounts, and .ssh from the dotfiles repository
# to the user's home directory. Then, a systemd service is registered and started
# to configure and start the NFS mounts defined in the .conf file.
# Each directory and file, including hidden files, within the target directories is recursively linked.
# Example: ./dotfiles/.mounts/.conf is linked to ~/.mounts/.conf
# Afterwards, the NFS mounts defined in .mounts/.conf are configured and started.


# function to link directories, including hidden files, from source_dir to target_dir
link_directory() {
    # link source_dir $1 to target_dir $2
    local source_dir="$1"
    local target_dir="$2"

    # check if the target directory exists, if not, create it
    if [ ! -d "$target_dir" ]; then
        echo "Verzeichnis $target_dir existiert nicht, wird erstellt..."
        mkdir -p "$target_dir"
        echo "mkdir -p $target_dir ausgeführt"
    fi

    # Use find to iterate through all files and directories in source_dir
    # For each file or directory, create a relative path by removing the source_dir path from the full path.
    # This relative path is then appended to target_dir to create the target path.
    # If the element is a directory, it is created.
    # If it is a file, a symbolic link is created.
    find "$source_dir" -mindepth 1 -exec bash -c '
        for filepath do
            local relative_path=${filepath#'"$source_dir"'}
            local target_path='"$target_dir"'$relative_path

            if [ -d "$filepath" ]; then
                # Es handelt sich um ein Verzeichnis
                mkdir -p "$target_path"
                echo "mkdir -p $target_path ausgeführt"
            elif [ -f "$filepath" ]; then
                # Es handelt sich um eine Datei
                ln -sfn "$filepath" "$target_path"
                echo "ln -sfn $filepath $target_path ausgeführt"
            fi
        done
    ' bash {} +
}

# link directories from dotfiles to user home
for dir in "${TARGET_DIRS[@]}"; do
    link_directory "$DOTFILES_DIR/$dir" "$USER_HOME/$dir"
done

# systemd service link to /etc/systemd/system, deamon-reload, enable and start service
if [ -f "$DOTFILES_DIR/.mounts/usermounts.service" ]; then
    echo "Register and start systemd service..."
    sudo ln -s "$USER_HOME/dotfiles/.mounts/usermounts.service" /etc/systemd/system/usermounts.service
    sudo systemctl daemon-reload
    sudo systemctl enable usermounts.service
    sudo systemctl start usermounts.service
else
    echo "File not found: $DOTFILES_DIR/.mounts/usermounts.service"
    exit 1
fi

echo "Setup complete."