#!/bin/bash

# install_packages.sh: Install packages from YAML config for multiple package managers

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"
source "$dotfiles_dir/functions.sh"

# Parse YAML file
parse_yaml() {
    local yaml_file="$1"
    python3 -c "
import yaml
with open('$yaml_file', 'r') as f:
    print(yaml.safe_load(f))
    "
}

# Install a single package using specified package manager
install_single_package() {
    local package_manager="$1"
    local package="$2"

    log_message "Attempting to install single package: $package with $package_manager" "cyan"

    if [ "$package_manager" = "pacman" ]; then
        sudo pacman -S --needed --noconfirm "$package" || log_message "Failed to install $package with pacman" "red"
    elif [ "$package_manager" = "yay" ]; then
        if ! command_exists yay; then
            log_message "yay is not installed. Installing yay..." "yellow"
            install_aur_helper
        fi
        yay -S --needed --noconfirm "$package" || log_message "Failed to install $package with yay" "red"
    else
        log_message "Unknown package manager: $package_manager" "red"
        return 1
    fi

    # Check if installation was successful
    if pacman -Qi "$package" &>/dev/null; then
        log_message "$package successfully installed" "green"
    else
        log_message "$package installation failed or package not found" "red"
    fi
}

# Install packages from a specific set or individual package
install_packages() {
    local yaml_file="$available_packages"
    local packages=("$@")

    log_message "Starting package installation. YAML file: $yaml_file" "yellow"
    log_message "Packages to install: ${packages[*]}" "yellow"

    local yaml_content=$(parse_yaml "$yaml_file")

    for package in "${packages[@]}"; do
        log_message "Checking package: $package" "cyan"
        
        if echo "$yaml_content" | grep -q "\"$package\""; then
            local package_manager=""
            if echo "$yaml_content" | grep -q "pacman.*$package"; then
                package_manager="pacman"
            elif echo "$yaml_content" | grep -q "yay.*$package"; then
                package_manager="yay"
            fi

            if [ -n "$package_manager" ]; then
                log_message "Package $package found in YAML, will be installed with $package_manager" "yellow"
                install_single_package "$package_manager" "$package"
            else
                log_message "Package $package found in YAML, but no package manager specified" "red"
            fi
        elif echo "$yaml_content" | grep -q "^$package:"; then
            log_message "Installing package group: $package" "yellow"
            local group_packages=$(echo "$yaml_content" | sed -n "/^$package:/,/^[^ ]/p" | grep -E '^ +- ' | sed 's/^ *- //')
            for group_package in $group_packages; do
                install_single_package "pacman" "$group_package" || install_single_package "yay" "$group_package"
            done
        else
            log_message "Package or group not found in YAML: $package" "red"
        fi
    done
}

# Main function
main() {
    log_message "install_packages.sh main function called with arguments: $@" "cyan"
    if [ "$#" -eq 0 ]; then
        log_message "No packages specified. Using default setup_install_packages." "yellow"
        install_packages $setup_install_packages
    else
        install_packages "$@"
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi