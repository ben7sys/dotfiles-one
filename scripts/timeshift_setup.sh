#!/bin/bash
set -x
# timeshift_setup.sh: Configure Timeshift for BTRFS snapshots with a systemd service
# This script should be run as a normal user. It will elevate privileges only for commands that require root.

# Avoid double sourcing by checking if DOTFILES_CONFIG is already sourced
[ -z "$DOTFILES_CONFIG_SOURCED" ] || return
export DOTFILES_CONFIG_SOURCED=1

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
    echo ""
    echo "Note: This script requires root privileges to run certain actions."
}

# Check for help argument
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_usage
    exit 0
fi

# Enable debug mode
set -x

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for config in "$SCRIPT_DIR/config.sh" "$SCRIPT_DIR/../config.sh"; do
    if [ -f "$config" ]; then
        # Source the config.sh only if it hasn't been sourced yet
        if ! (return 2>/dev/null); then
            source "$config"
            echo "Found and sourced: $config"
        else
            echo "config.sh already sourced: $config"
        fi
        exit 0
    fi
done

# If no config.sh is found, output an error and exit
echo "Error: config.sh not found." >&2
exit 1

# Ensure required packages are installed
if ! command_exists "timeshift" || ! command_exists "grub-btrfs" || ! command_exists "snapd"; then
    echo "Required packages not found. Installing timeshift, snapd, and grub-btrfs..."
    sudo bash "$DOTFILES_DIR/scripts/install_packages.sh" timeshift snapd grub-btrfs
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
