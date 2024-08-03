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
    local yaml_file="$available_packages"
    local packages=("$@")

    for package in "${packages[@]}"; do
        if [[ "$package" == packages_* ]]; then
            # Install package set
            local set_var="set_of_$package"
            if [ -n "${!set_var}" ]; then
                log_message "Installing package set: $package" "cyan"
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
                if confirm "Do you want to install $package?"; then
                    install_single_package "$package_manager" "$package"
                else
                    log_message "Skipping installation of $package" "yellow"
                fi
            else
                log_message "Package not found in YAML: $package" "red"
            fi
        fi
    done
}

# Main function
main() {
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