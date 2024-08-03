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
            log_message "Installing $package with pacman as root" "yellow"
            pacman -S --needed --noconfirm "$package" || log_message "Failed to install $package with pacman" "red"
        else
            log_message "Installing $package with pacman using sudo" "yellow"
            sudo pacman -S --needed --noconfirm "$package" || log_message "Failed to install $package with pacman" "red"
        fi
        if pacman -Qi "$package" >/dev/null 2>&1; then
            log_message "$package successfully installed with pacman" "green"
        else
            log_message "$package installation with pacman failed or package not found" "red"
        fi
    elif [ "$package_manager" = "yay" ]; then
        if ! command_exists yay; then
            log_message "yay is not installed. Installing yay..." "yellow"
            install_aur_helper
        fi
        log_message "Installing $package with yay" "yellow"
        yay -S --needed --noconfirm "$package" || log_message "Failed to install $package with yay" "red"
        if yay -Qi "$package" >/dev/null 2>&1; then
            log_message "$package successfully installed with yay" "green"
        else
            log_message "$package installation with yay failed or package not found" "red"
        fi
    else
        log_message "Unknown package manager: $package_manager" "red"
        return 1
    fi
}

# Install packages from a specific set or individual package
install_packages() {
    local yaml_file="$available_packages"
    local packages=("$@")

    log_message "Starting package installation. YAML file: $yaml_file" "yellow"
    log_message "Packages to install: ${packages[*]}" "yellow"

    for package in "${packages[@]}"; do
        log_message "Checking package: $package" "cyan"
        
        local package_manager=$(yq e ".pacman[] | select(. == \"$package\")" "$yaml_file" 2>/dev/null)
        if [ -z "$package_manager" ]; then
            package_manager=$(yq e ".yay[] | select(. == \"$package\")" "$yaml_file" 2>/dev/null)
            [ -n "$package_manager" ] && package_manager="yay"
        else
            package_manager="pacman"
        fi

        log_message "Package $package will be installed with $package_manager" "yellow"
        
        if [ -n "$package_manager" ]; then
            install_single_package "$package_manager" "$package"
        else
            log_message "Package not found in YAML: $package" "red"
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