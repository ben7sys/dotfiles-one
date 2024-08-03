#!/bin/bash

# timeshift_setup.sh: Configure Timeshift and Snapper for BTRFS snapshots

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"
source "$SCRIPT_DIR/../functions.sh"

# Check if running as root
check_root || { log_message "This script must be run as root" "red"; exit 1; }

# Function to check Timeshift-specific requirements
check_timeshift_requirements() {
    log_message "Checking Timeshift-specific requirements..." "yellow"
    
    # Check for BTRFS filesystem
    if ! mount | grep -q "type btrfs"; then
        log_message "BTRFS filesystem not detected. Timeshift requires BTRFS for snapshots." "red"
        return 1
    fi

    # Check available disk space (example: 5GB free space required)
    local free_space=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$free_space" -lt 5 ]; then
        log_message "Less than 5GB free space available. This might not be enough for snapshots." "yellow"
        return 1
    fi

    # Check if required commands are available
    local required_commands=(timeshift snapper grub-mkconfig)
    for cmd in "${required_commands[@]}"; do
        if ! command_exists "$cmd"; then
            log_message "Required command not found: $cmd" "red"
            return 1
        fi
    done

    log_message "All Timeshift-specific requirements are met." "green"
    return 0
}

# Main function
main() {
    log_message "Starting Timeshift and Snapper setup..." "cyan"

    check_requirements || { log_message "Failed to meet general system requirements. Exiting." "red"; exit 1; }
    check_timeshift_requirements || { log_message "Failed to meet Timeshift-specific requirements. Exiting." "red"; exit 1; }

    # Install necessary packages
    install_packages timeshift snapper grub-btrfs

    # Configure Timeshift for system (excluding /home)
    if ! timeshift --list | grep -q "btrfs"; then
        log_message "Configuring Timeshift for system snapshots..." "yellow"
        timeshift --btrfs --snapshot-device /dev/sda2 --exclude "/home/**" --create || { log_message "Failed to configure Timeshift" "red"; exit 1; }
    else
        log_message "Timeshift is already configured for BTRFS" "green"
    fi

    # Configure Snapper for /home
    if ! snapper list-configs | grep -q "home"; then
        log_message "Configuring Snapper for /home snapshots..." "yellow"
        snapper -c home create-config /home || { log_message "Failed to configure Snapper for /home" "red"; exit 1; }
    else
        log_message "Snapper is already configured for /home" "green"
    fi

    # Create Systemd units for automatic snapshots
    create_systemd_service "timeshift-boot-snapshot" "/usr/bin/timeshift --create --comments 'Auto snapshot after boot' --tags B"
    create_systemd_service "snapper-boot-snapshot" "/usr/bin/snapper -c home create -c timeline -d 'Auto snapshot after boot'"

    # Configure GRUB to show snapshots
    if ! grep -q "GRUB_DISABLE_SUBMENU=n" /etc/default/grub; then
        log_message "Configuring GRUB to show snapshots..." "yellow"
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
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi