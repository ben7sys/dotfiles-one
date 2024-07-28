#!/bin/bash

# setup.sh: Automate system setup and dotfiles installation for multiple operating systems

set -euo pipefail

# Source common functions and system configuration
source "$(dirname "$0")/common_functions.sh"
source "$(dirname "$0")/configure_system.sh"

# Main directories
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup"

# In setup.sh
"$DOTFILES_DIR/scripts/install_packages.sh" "$DOTFILES_DIR/packages_arch.json" core extended

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