#!/bin/bash

# install_packages.sh: Install packages from YAML config for multiple package managers

set -eo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../functions.sh"

# Install packages using specified package manager
install_packages() {
    local package_manager="$1"
    shift
    local packages=("$@")

    for package in "${packages[@]}"; do
        if [ "$package_manager" = "pacman" ]; then
            sudo pacman -S --needed --noconfirm "$package" || log_message "Failed to install $package with pacman" "yellow"
        elif [ "$package_manager" = "yay" ]; then
            yay -S --needed --noconfirm "$package" || log_message "Failed to install $package with yay" "yellow"
        fi
    done
}

# Main function to process YAML and install packages
main() {
    local yaml_file="$1"
    shift
    local modules=("$@")

    if [ ! -f "$yaml_file" ]; then
        log_message "Package YAML file not found: $yaml_file" "red"
        exit 1
    fi

    # Update system packages
    log_message "Updating system packages..." "yellow"
    sudo pacman -Syu --noconfirm

    for module in "${modules[@]}"; do
        log_message "Processing module: $module" "cyan"
        
        # Install pacman packages
        mapfile -t pacman_packages < <(yq e ".$module.pacman[]" "$yaml_file" 2>/dev/null)
        if [ ${#pacman_packages[@]} -gt 0 ]; then
            log_message "Installing pacman packages for $module..." "cyan"
            install_packages "pacman" "${pacman_packages[@]}"
        fi

        # Install yay packages
        mapfile -t yay_packages < <(yq e ".$module.yay[]" "$yaml_file" 2>/dev/null)
        if [ ${#yay_packages[@]} -gt 0 ]; then
            if ! command_exists yay; then
                log_message "yay is required but not installed. Installing yay..." "yellow"
                install_aur_helper
            fi
            log_message "Installing yay packages for $module..." "magenta"
            install_packages "yay" "${yay_packages[@]}"
        fi
    done
}

# Script entry point
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <yaml_file> <module1> [<module2> ...]"
    exit 1
fi

yaml_file="$1"
shift

main "$yaml_file" "$@"

log_message "Package installation process completed!" "green"