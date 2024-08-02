#!/bin/bash

# install_packages.sh: A script to install packages from a YAML configuration file

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_functions.sh"

# Main function to install packages
install_packages() {
    local yaml_file="$1"
    shift
    local modules=("$@")

    if [ ! -f "$yaml_file" ]; then
        log_message "Package YAML file not found: $yaml_file" "red"
        exit 1
    fi

    # Check if yq is installed
    if ! command_exists yq; then
        log_message "yq is required but not installed. Installing yq..." "yellow"
        sudo pacman -S --noconfirm yq
    fi

    # Update the system first
    log_message "Updating system packages..." "yellow"
    sudo pacman -Syu --noconfirm

    for module in "${modules[@]}"; do
        log_message "Installing packages for module: $module" "yellow"
        
        # Install pacman packages
        pacman_packages=$(yq eval "$module.pacman[]" "$yaml_file")
        if [ -n "$pacman_packages" ]; then
            log_message "Installing pacman packages for $module..." "cyan"
            echo "$pacman_packages" | sudo pacman -S --needed --noconfirm -
        fi

        # Install yay packages
        yay_packages=$(yq eval ".$module.yay[]" "$yaml_file")
        if [ -n "$yay_packages" ]; then
            if ! command_exists yay; then
                log_message "yay is required but not installed. Installing yay..." "yellow"
                install_aur_helper
            fi
            log_message "Installing yay packages for $module..." "magenta"
            echo "$yay_packages" | yay -S --needed --noconfirm -
        fi
    done
}

# Main execution
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <yaml_file> <module1> [<module2> ...]"
    exit 1
fi

yaml_file="$1"
shift
modules=("$@")

install_packages "$yaml_file" "${modules[@]}"

log_message "Package installation completed successfully!" "green"