#!/bin/bash

# timeshift_setup.sh: Configure Timeshift and Snapper for BTRFS snapshots

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"
source "$dotfiles_dir/functions.sh"

check_root || { log_message "This script must be run as root" "red"; exit 1; }

# Install necessary packages
packages_to_install="timeshift snapper grub-btrfs"
log_message "Installing required packages..." "yellow"
install_packages $packages_to_install || { log_message "Failed to install packages" "red"; exit 1; }

# Configure Timeshift for system (excluding /home)
log_message "Configuring Timeshift for system snapshots..." "yellow"
timeshift --btrfs --snapshot-device /dev/sda2 --exclude "/home/**" --create || { log_message "Failed to configure Timeshift" "red"; exit 1; }

# Configure Snapper for /home
log_message "Configuring Snapper for /home snapshots..." "yellow"
snapper -c home create-config /home || { log_message "Failed to configure Snapper for /home" "red"; exit 1; }

# Create Systemd units for automatic snapshots
create_systemd_service "timeshift-boot-snapshot" "/usr/bin/timeshift --create --comments 'Auto snapshot after boot' --tags B"
create_systemd_service "snapper-boot-snapshot" "/usr/bin/snapper -c home create -c timeline -d 'Auto snapshot after boot'"

# Configure GRUB to show snapshots
log_message "Configuring GRUB to show snapshots..." "yellow"
sed -i 's/GRUB_DISABLE_SUBMENU=y/GRUB_DISABLE_SUBMENU=n/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg || { log_message "Failed to update GRUB configuration" "red"; exit 1; }

log_message "Snapshot configuration completed." "green"
log_message "System snapshots (excluding /home) will be managed by Timeshift." "cyan"
log_message "/home snapshots will be managed by Snapper." "cyan"
log_message "Snapshots will be available in the GRUB menu at boot." "cyan"
log_message "To manage snapshots manually:" "yellow"
log_message "  - For system: use 'timeshift' command" "yellow"
log_message "  - For /home: use 'snapper -c home' commands" "yellow"