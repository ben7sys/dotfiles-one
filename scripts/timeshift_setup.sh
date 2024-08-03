#!/bin/bash

# timeshift_setup.sh: Configure Timeshift and Snapper for BTRFS snapshots

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"
source "$dotfiles_dir/functions.sh"

check_root || { log_message "This script must be run as root" "red"; exit 1; }

# Install necessary packages if not already installed
install_if_not_exists() {
    local package="$1"
    if ! command_exists "$package"; then
        log_message "Installing $package..." "yellow"
        pacman -S --noconfirm "$package" || { log_message "Failed to install $package" "red"; exit 1; }
    else
        log_message "$package is already installed" "green"
    fi
}

packages_to_install="timeshift snapper grub-btrfs"
for package in $packages_to_install; do
    install_if_not_exists "$package"
done

# Configure Timeshift for system (excluding /home)
log_message "Configuring Timeshift for system snapshots..." "yellow"
if ! timeshift --list | grep -q "btrfs"; then
    timeshift --btrfs --snapshot-device /dev/sda2 --exclude "/home/**" --create || { log_message "Failed to configure Timeshift" "red"; exit 1; }
else
    log_message "Timeshift is already configured for BTRFS" "green"
fi

# Configure Snapper for /home
log_message "Configuring Snapper for /home snapshots..." "yellow"
if ! snapper list-configs | grep -q "home"; then
    snapper -c home create-config /home || { log_message "Failed to configure Snapper for /home" "red"; exit 1; }
else
    log_message "Snapper is already configured for /home" "green"
fi

# Create Systemd units for automatic snapshots
create_systemd_service "timeshift-boot-snapshot" "/usr/bin/timeshift --create --comments 'Auto snapshot after boot' --tags B"
create_systemd_service "snapper-boot-snapshot" "/usr/bin/snapper -c home create -c timeline -d 'Auto snapshot after boot'"

# Configure GRUB to show snapshots
log_message "Configuring GRUB to show snapshots..." "yellow"
if ! grep -q "GRUB_DISABLE_SUBMENU=n" /etc/default/grub; then
    sed -i 's/GRUB_DISABLE_SUBMENU=y/GRUB_DISABLE_SUBMENU=n/' /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg || { log_message "Failed to update GRUB configuration" "red"; exit 1; }
else
    log_message "GRUB is already configured to show submenus" "green"
fi

log_message "Snapshot configuration completed." "green"
log_message "System snapshots (excluding /home) will be managed by Timeshift." "cyan"
log_message "/home snapshots will be managed by Snapper." "cyan"
log_message "Snapshots will be available in the GRUB menu at boot." "cyan"
log_message "To manage snapshots manually:" "yellow"
log_message "  - For system: use 'timeshift' command" "yellow"
log_message "  - For /home: use 'snapper -c home' commands" "yellow"