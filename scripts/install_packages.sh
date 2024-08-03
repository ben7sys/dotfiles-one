#!/bin/bash

# install_packages.sh: Install packages from YAML config for multiple package managers

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"
source "$dotfiles_dir/functions.sh"

# Install a single package using specified package manager
install_single_package() {
    local package_manager="$1"
    local package="$2"

    log_message "Attempting to install single package: $package with $package_manager" "cyan"

    if [ "$package_manager" = "pacman" ]; then
        if check_root; then
            pacman -S --needed --noconfirm "$package" || log_message "Failed to install $package with pacman" "yellow"
        else
            sudo pacman -S --needed --noconfirm "$package" || log_message "Failed to install $package with pacman" "yellow"
        fi
    elif [ "$package_manager" = "yay" ]; then
        if ! command_exists yay; then
            log_message "yay is not installed. Installing yay..." "yellow"
            install_aur_helper
        fi
        yay -S --needed --noconfirm "$package" || log_message "Failed to install $package with yay" "yellow"
    else
        log_message "Unknown package manager: $package_manager" "red"
        return 1
    fi
}

# Install packages from a specific set or individual package
install_packages() {
    log_message "install_packages function called with arguments: $@" "cyan"
    local yaml_file="$available_packages"
    local packages=("$@")

    log_message "Starting package installation. YAML file: $yaml_file" "yellow"
    log_message "Packages to install: ${packages[*]}" "yellow"

    for package in "${packages[@]}"; do
        log_message "Processing package: $package" "cyan"
        
        # Check if it's a package set
        if [[ "$package" == packages_* ]]; then
            log_message "Detected as package set: $package" "cyan"
            local set_var="set_of_$package"
            if [ -n "${!set_var}" ]; then
                install_packages ${!set_var}
            else
                log_message "Package set not found: $package" "red"
            fi
        else
            # Install individual package
            local package_manager=$(yq e ".pacman[] | select(. == \"$package\")" "$yaml_file" 2>/dev/null)
            if [ -z "$package_manager" ]; then
                package_manager=$(yq e ".yay[] | select(. == \"$package\")" "$yaml_file" 2>/dev/null)
                [ -n "$package_manager" ] && package_manager="yay"
            else
                package_manager="pacman"
            fi

            if [ -n "$package_manager" ]; then
                log_message "Installing package: $package with $package_manager" "cyan"
                install_single_package "$package_manager" "$package"
            else
                log_message "Package not found in YAML: $package" "red"
            fi
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