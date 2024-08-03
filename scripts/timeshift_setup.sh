#!/bin/bash

# timeshift_setup.sh: Configure Timeshift for BTRFS snapshots with a systemd service
# This script should be run as a normal user. It will elevate privileges only for commands that require root.

# Function to display usage information
show_usage() {
    echo "Usage: $0 [DOTFILES_DIR]"
    echo "  or:  DOTFILES_DIR=/path/to/dotfiles $0"
    echo ""
    echo "This script configures Timeshift for BTRFS snapshots."
    echo "It can be run either through setup.sh or manually with the dotfiles directory specified."
    echo ""
    echo "If run manually, you must either:"
    echo "  1. Provide the path to your dotfiles directory as an argument, or"
    echo "  2. Set the DOTFILES_DIR environment variable before running the script."
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

# Ensure required packages are installed
if ! command_exists "timeshift"; then
    echo "Timeshift not found. Installing..."
    sudo bash "$dotfiles_dir/install_packages.sh" timeshift snapd
fi

# Backup and modify GRUB configuration
backup_grub_config() {
    echo "Backing up current GRUB configuration..."
    sudo cp /etc/default/grub /etc/default/grub.bak
}

modify_grub_config() {
    echo "Modifying GRUB configuration to include BTRFS snapshots..."
    sudo sed -i 's/^GRUB_TIMEOUT=.*$/GRUB_TIMEOUT=10/' /etc/default/grub
    sudo sed -i 's/^#GRUB_SAVEDEFAULT=true$/GRUB_SAVEDEFAULT=true/' /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg
}

# Create and enable a systemd service for Timeshift snapshots
create_systemd_service() {
    echo "Creating systemd service for Timeshift snapshots..."
    sudo bash -c 'cat <<EOF > /etc/systemd/system/timeshift-autosnap.service
[Unit]
Description=Timeshift snapshot on boot
DefaultDependencies=no
Before=grub-initrd-fallback.service

[Service]
Type=oneshot
ExecStart=/usr/bin/timeshift --create --comments "Snapshot on boot"

[Install]
WantedBy=default.target
EOF'
    sudo systemctl daemon-reload
    sudo systemctl enable timeshift-autosnap.service
}

# Main setup tasks
backup_grub_config
modify_grub_config
create_systemd_service

echo "Timeshift setup complete. Please reboot to apply the new configuration."
