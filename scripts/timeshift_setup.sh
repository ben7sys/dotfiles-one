#!/bin/bash

## timeshift_setup.sh: Configure Timeshift for BTRFS snapshots with a systemd service
## This script should be run as a normal user. It will elevate privileges only for commands that require root.

## Enable debug mode
#set -x

## Enable strict mode
set -eo pipefail

# Determine the script's directory and the parent directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

## --- Source files ---
## Prevent duplicate sourcing for any file
source_file_if_not_sourced() {
    local file_path="$1"
    local file_var_name="SOURCED_${file_path//[^a-zA-Z0-9_]/_}"
    
    if [ -f "$file_path" ]; then
        # Verwenden von `declare -n` für die indirekte Variablenreferenz
        declare -n file_var_ref="$file_var_name"
        if [ -z "$file_var_ref" ]; then
            source "$file_path"
            file_var_ref=1
        fi
    else
        echo "Error: $file_path not found." >&2
        exit 1
    fi
}

# Source the config.sh file from the same directory or a parent directory
source_file_if_not_sourced "$PARENT_DIR/config.sh"
source_file_if_not_sourced "$PARENT_DIR/functions.sh"
source_file_if_not_sourced "$DOTFILES_DIR/scripts/install_packages.sh"
#log_message "config and functions sourced" "yellow"

# Function to check Timeshift-specific requirements
check_timeshift_requirements() {
    log_message "Checking Timeshift-specific requirements..." "yellow"
    
    local required_packages=("timeshift" "grub-btrfs" "snapd")
    local missing_packages=()

    for pkg in "${required_packages[@]}"; do
        if ! command_exists "$pkg"; then
            missing_packages+=("$pkg")
        fi
    done

    if [ ${#missing_packages[@]} -ne 0 ]; then
        log_message "Installing missing packages: ${missing_packages[*]}" "yellow"
        install_packages "${missing_packages[@]}"
    fi

    log_message "All Timeshift-specific requirements are met." "green"
}

# Function to backup and modify GRUB configuration
modify_grub_config() {
    log_message "Modifying GRUB configuration..." "yellow"

    sudo cp /etc/default/grub /etc/default/grub.bak
    sudo sed -i 's/^GRUB_TIMEOUT=.*$/GRUB_TIMEOUT=10/' /etc/default/grub
    sudo sed -i 's/^GRUB_SAVEDEFAULT=true$/#GRUB_SAVEDEFAULT=true/' /etc/default/grub
    
    if ! grep -q "^GRUB_DISABLE_OS_PROBER=false" /etc/default/grub; then
        echo "GRUB_DISABLE_OS_PROBER=false" | sudo tee -a /etc/default/grub
    fi

    sudo grub-mkconfig -o /boot/grub/grub.cfg
    log_message "GRUB configuration updated." "green"
}

# Function to create and enable systemd service for Timeshift
create_timeshift_service() {
    log_message "Creating systemd service for Timeshift snapshots..." "yellow"
    
    local service_content="[Unit]
Description=Timeshift snapshot on boot
DefaultDependencies=no
Before=grub-initrd-fallback.service

[Service]
Type=oneshot
ExecStart=/usr/bin/timeshift --create --comments \"Snapshot on boot\"

[Install]
WantedBy=default.target"

    echo "$service_content" | sudo tee /etc/systemd/system/timeshift-autosnap.service > /dev/null
    sudo systemctl daemon-reload
    sudo systemctl enable timeshift-autosnap.service
    
    log_message "Timeshift systemd service created and enabled." "green"
}

# Main function
main() {
    log_message "Starting Timeshift setup..." "cyan"

    check_not_root || { log_message "This script should not be run as root" "red"; exit 1; }
    check_requirements
    check_timeshift_requirements

    modify_grub_config
    create_timeshift_service

    log_message "Timeshift setup complete. Please reboot to apply the new configuration." "green"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi