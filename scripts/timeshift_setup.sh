#!/bin/bash

# timeshift_setup.sh: Configure Timeshift and Snapper for BTRFS snapshots

# Function to display usage information
show_usage() {
    echo "Usage: $0 [DOTFILES_DIR]"
    echo "  or:  DOTFILES_DIR=/path/to/dotfiles $0"
    echo ""
    echo "This script configures Timeshift and Snapper for BTRFS snapshots."
    echo "It can be run either through setup.sh or manually with the dotfiles directory specified."
    echo ""
    echo "If run manually, you must either:"
    echo "  1. Provide the path to your dotfiles directory as an argument, or"
    echo "  2. Set the DOTFILES_DIR environment variable before running the script."
    echo ""
    echo "Example:"
    echo "  $0 \$HOME/.dotfiles"
    echo "  or"
    echo "  DOTFILES_DIR=\$HOME/.dotfiles $0"
    echo ""
    echo "Note: This script requires root privileges to run certain actions."
}

# Check for help argument
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_usage
    exit 0
fi

# Determine dotfiles directory
if [ -n "$DOTFILES_DIR" ]; then
    dotfiles_dir="$DOTFILES_DIR"
    echo "Using DOTFILES_DIR from environment variable: $dotfiles_dir"
elif [ -n "$1" ]; then
    dotfiles_dir="$1"
    echo "Using DOTFILES_DIR from command line argument: $dotfiles_dir"
else
    echo "Error: DOTFILES_DIR not set and no argument provided." >&2
    echo ""
    show_usage
    exit 1
fi

# Verify that dotfiles_dir exists and is a directory
if [ ! -d "$dotfiles_dir" ]; then
    echo "Error: $dotfiles_dir is not a valid directory." >&2
    exit 1
fi

# Source the config file and functions
if [ -f "$dotfiles_dir/config.sh" ]; then
    source "$dotfiles_dir/config.sh"
else
    echo "Error: config.sh not found in $dotfiles_dir" >&2
    exit 1
fi

if [ -f "$dotfiles_dir/functions.sh" ]; then
    source "$dotfiles_dir/functions.sh"
else
    echo "Error: functions.sh not found in $dotfiles_dir" >&2
    exit 1
fi

# Install Timeshift and required packages
install_packages "timeshift snapd"

# Detect the BTRFS root partition
btrfs_root=$(findmnt -n -o SOURCE / | grep "^/dev/")

if [ -z "$btrfs_root" ]; then
    echo "Error: BTRFS root partition not found."
    exit 1
fi

# Use detected BTRFS root partition
timeshift --snapshot-device "$btrfs_root" --schedule daily --target /mnt/timeshift --create

# Create and enable Systemd service to run Timeshift 1 minute after boot
create_systemd_service() {
    service_name="timeshift-snapshot"
    service_file="/etc/systemd/system/$service_name.service"

    echo "[Unit]
Description=Create Timeshift Snapshot after Boot
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/timeshift --create --comments \"Auto snapshot after boot\"
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target" > "$service_file"

    # Enable the service
    systemctl daemon-reload
    systemctl enable "$service_name"
}

create_systemd_service

# Backup and update GRUB configuration
backup_and_update_grub() {
    grub_cfg="/etc/default/grub"
    backup_cfg="/etc/default/grub.bak"

    # Backup existing GRUB configuration
    cp "$grub_cfg" "$backup_cfg"

    # Update GRUB configuration to include BTRFS snapshots
    sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 btrfs"/' "$grub_cfg"

    # Apply new GRUB configuration
    update-grub
}

backup_and_update_grub

echo "Timeshift setup and configuration completed successfully."
