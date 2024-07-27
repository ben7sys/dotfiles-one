#!/bin/bash

# setup.sh: Automate system setup and dotfiles installation for multiple operating systems

set -euo pipefail

# Source common functions and system configuration
source "$(dirname "$0")/common_functions.sh"
source "$(dirname "$0")/configure_system.sh"

# Main directories
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup"

# Function to install packages based on OS
install_os_packages() {
    local os=$1
    local package_file="$DOTFILES_DIR/install/packages_${os}.txt"

    if [ ! -f "$package_file" ]; then
        log_message "Package list for $os not found: $package_file" "red"
        return 1
    fi

    log_message "Installing packages for $os..." "yellow"
    case $os in
        arch)
            install_packages "$package_file"
            install_aur_helper
            if command_exists yay; then
                log_message "Updating system including AUR packages..." "yellow"
                yay -Syu --noconfirm
            fi
            ;;
        debian|fedora)
            install_packages "$package_file"
            ;;
        macos)
            if ! command_exists brew; then
                log_message "Installing Homebrew..." "yellow"
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            install_packages "$package_file"
            ;;
        *)
            log_message "Unsupported operating system: $os" "red"
            return 1
            ;;
    esac
}

# Main function to orchestrate the setup
main() {
    local os=$(check_os)
    log_message "Starting setup process for $os..." "green"
    
    check_not_root
    check_requirements
    backup_dotfiles "$DOTFILES_DIR" "$BACKUP_DIR"
    
    if ! install_os_packages "$os"; then
        log_message "Failed to install packages. Exiting." "red"
        exit 1
    fi
    
    stow_dotfiles "$DOTFILES_DIR" "$HOME" "home"
    configure_system
    setup_user_env
    
    log_message "Setup completed successfully!" "green"
    log_message "Please restart your shell or source your .bashrc for changes to take effect." "yellow"
}

# Run the main function
main