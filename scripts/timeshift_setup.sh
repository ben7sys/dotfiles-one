#!/bin/bash

## timeshift_setup.sh: Configure Timeshift for BTRFS snapshots with a systemd service
## This script should be run as a normal user. It will elevate privileges only for commands that require root.

## Enable debug mode
set -x

## Enable strict mode
#set -eo pipefail

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
log_message "config and functions sourced" "yellow"


## --- Functions ---
# Function to display usage information
show_usage() {
    echo "Usage: $0 [DOTFILES_DIR]"
    echo "  or:  DOTFILES_DIR=/path/to/dotfiles $0"
    echo ""
    echo "This script configures Timeshift for BTRFS snapshots."
    echo ""
    echo "Options:"
    echo "  -h, --help           Display this help message and exit"
    echo ""
    echo "Environment Variables:"
    echo "  DOTFILES_DIR         Path to the dotfiles directory (default: \$HOME/.dotfiles)"
    echo ""
    echo "Examples:"
    echo "  $0 \$HOME/.dotfiles"
    echo "  DOTFILES_DIR=\$HOME/.dotfiles $0"
    echo "  $DOTFILES_DIR
    echo ""
    echo "Note: This script requires root privileges to run certain actions."
}

# Check for help argument
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_usage
    exit 0
fi

# Ensure required packages are installed
missing_packages=()

# Check each required package
for pkg in "timeshift" "grub-btrfs" "snapd"; do
    if ! command_exists "$pkg"; then
        missing_packages+=("$pkg")
    fi
done

# Install missing packages if any
if [ ${#missing_packages[@]} -ne 0 ]; then
    echo "Required packages not found. Installing ${missing_packages[*]}..."
    sudo bash "$DOTFILES_DIR/scripts/install_packages.sh" "${missing_packages[@]}"
fi

# Install AUR helper (yay) if not installed
install_aur_helper

# Backup and modify GRUB configuration
backup_grub_config() {
    echo "Backing up current GRUB configuration..."
    sudo cp /etc/default/grub /etc/default/grub.bak
}

modify_grub_config() {
    echo "Modifying GRUB configuration to include BTRFS snapshots and detect other operating systems..."

    # Set GRUB timeout to 10 seconds
    sudo sed -i 's/^GRUB_TIMEOUT=.*$/GRUB_TIMEOUT=10/' /etc/default/grub

    # Disable GRUB_SAVEDEFAULT to prevent sparse file errors
    sudo sed -i 's/^GRUB_SAVEDEFAULT=true$/#GRUB_SAVEDEFAULT=true/' /etc/default/grub

    # Enable OS Prober to detect other operating systems
    if grep -q "^#GRUB_DISABLE_OS_PROBER=true" /etc/default/grub; then
        sudo sed -i 's/^#GRUB_DISABLE_OS_PROBER=true/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
    else
        echo "GRUB_DISABLE_OS_PROBER=false" | sudo tee -a /etc/default/grub
    fi

    # Generate new GRUB configuration
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
