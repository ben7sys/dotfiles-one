#!/bin/bash

# install_packages.sh: Install packages from YAML config for multiple package managers
echo "Arguments passed to main: $@"

## Enable debug mode
set -x

## Enable strict mode
# set -eo pipefail

## --- Source files ---
## Prevent duplicate sourcing for any file
source_file_if_not_sourced() {
    local file_path="$1"
    local file_var_name="SOURCED_${file_path//[^a-zA-Z0-9_]/_}"
    if [ -f "$file_path" ]; then
        if [ -z "${!file_var_name}" ]; then
            source "$file_path"
            export "$file_var_name"=1
        fi
    else
        echo "Error: $file_path not found." >&2
        exit 1
    fi
}

## Source necessary files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source_file_if_not_sourced "$DOTFILES_ROOT_DIR/config.sh"

# Check requirements before proceeding
check_requirements

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

    if pacman -Qi "$package" &>/dev/null; then
        log_message "$package successfully installed" "green"
    else
        log_message "$package installation failed or package not found" "red"
    fi
}

# Install packages from a specific set or individual package
install_packages() {
    local yaml_file="${available_packages:-$DOTFILES_DIR/packages.yaml}"
    local packages=("$@")

    log_message "Starting package installation. YAML file: $yaml_file" "yellow"
    log_message "Packages to install: ${packages[*]}" "yellow"

    local yaml_content=$(parse_yaml "$yaml_file")
    log_message "YAML content after parsing: $yaml_content" "cyan"

    for package in "${packages[@]}"; do
        log_message "Checking package: $package" "cyan"
        
        if echo "$yaml_content" | grep -q "^pacman:$package$"; then
            log_message "$package found in pacman list" "green"
            install_single_package "pacman" "$package"
        elif echo "$yaml_content" | grep -q "^yay:$package$"; then
            log_message "$package found in yay list" "green"
            install_single_package "yay" "$package"
        elif echo "$yaml_content" | grep -q "^$package:"; then
            log_message "Installing package group: $package" "yellow"
            local group_packages=$(echo "$yaml_content" | grep "^$package:" | cut -d':' -f2)
            for group_package in $group_packages; do
                if echo "$yaml_content" | grep -q "^pacman:$group_package$"; then
                    install_single_package "pacman" "$group_package"
                elif echo "$yaml_content" | grep -q "^yay:$group_package$"; then
                    install_single_package "yay" "$group_package"
                else
                    log_message "Package $group_package not found in pacman or yay lists" "red"
                fi
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