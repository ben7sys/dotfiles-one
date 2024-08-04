#!/bin/bash

# install_packages.sh: Install packages from YAML config for multiple package managers

## Enable debug mode if needed
# set -x

## Enable strict mode
set -eo pipefail

# Source the config file
source "$(dirname "$0")/config.sh"

# Main function to orchestrate the setup
main() {
    local os=$(check_os)
    log_message "Starting setup process for $os..." "green"
    
    ensure_correct_location
    check_not_root
    check_requirements
    
    log_message "Trying to backup the existing dotfiles" "yellow"
    # Backup existing dotfiles before proceeding
    backup_dotfiles

    log_message "Trying to stow the dotfiles" "yellow"
    # Stow the dotfiles   
    "$SCRIPTS_DIR/stow.sh"

    # Execute system-specific configuration script
    #"$SCRIPTS_DIR/scripts/configure_system.sh"

    # Try to install packages
    install_packages $setup_install_packages
    
    # Run Timeshift setup
    log_message "Starting $SCRIPTS_DIR/timeshift_setup.sh" "yellow"
    "$SCRIPTS_DIR/timeshift_setup.sh"

    log_message "Setup completed successfully!" "green"
    log_message "Please restart your shell or source your .bashrc for changes to take effect." "yellow"
    log_message "Your original dotfiles have been backed up to $dotfiles_backup_dir" "cyan"
}

# Run the main function if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi