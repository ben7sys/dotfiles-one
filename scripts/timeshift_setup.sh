#!/bin/bash

# timeshift_setup.sh: Configure Timeshift for BTRFS snapshots and automatic backups

# Source the config and functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"
source "$SCRIPT_DIR/../functions.sh"

# Check if running as root
check_root || { log_message "This script must be run as root" "red"; exit 1; }

# Install Timeshift if not already installed
if ! command_exists timeshift; then
    log_message "Installing Timeshift..." "yellow"
    install_packages timeshift || { log_message "Failed to install Timeshift" "red"; exit 1; }
fi

# Ensure the filesystem is BTRFS
if ! timeshift --list | grep -q "BTRFS"; then
    log_message "BTRFS filesystem is required. Please check your configuration." "red"
    exit 1
fi

# Create initial snapshot configuration directory if not exists
ensure_dir_exists /etc/timeshift

# Configure Timeshift for BTRFS snapshots
log_message "Configuring Timeshift for BTRFS snapshots..." "yellow"
timeshift --snapshot-device /dev/sda1 --create --btrfs || { log_message "Failed to configure Timeshift" "red"; exit 1; }

# Create Systemd unit for automatic snapshot after boot
SYSTEMD_SERVICE="/etc/systemd/system/timeshift-boot-snapshot.service"
SERVICE_CONTENT=$(cat << 'EOF'
[Unit]
Description=Create Timeshift snapshot after boot
After=default.target

[Service]
ExecStart=/usr/bin/timeshift --create --comments "Auto snapshot after boot" --tags D --scripted
Type=oneshot

[Install]
WantedBy=default.target
EOF
)

# Create Systemd service file
echo "$SERVICE_CONTENT" | tee "$SYSTEMD_SERVICE" > /dev/null

# Enable the Systemd unit
systemctl daemon-reload
systemctl enable timeshift-boot-snapshot.service

# Install grub-btrfs to make snapshots available in GRUB menu
if ! command_exists grub-btrfs; then
    log_message "Installing grub-btrfs..." "yellow"
    install_packages grub-btrfs || { log_message "Failed to install grub-btrfs" "red"; exit 1; }
fi

# Update GRUB configuration to show snapshots
log_message "Updating GRUB configuration..." "yellow"
grub-mkconfig -o /boot/grub/grub.cfg || { log_message "Failed to update GRUB configuration" "red"; exit 1; }

log_message "Timeshift configuration completed. Snapshots will now be created automatically after each boot and shown in the GRUB menu." "green"