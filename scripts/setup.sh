#!/bin/bash

# install_packages.sh: Install packages from YAML config for multiple package managers

## Enable debug mode if needed
# set -x

## Enable strict mode
set -eo pipefail

# Source the config file
source "$(dirname "$0")/config.sh"

# Ensure the script is in the coreect location
ensure_correct_location() {
    local current_dir=$(pwd)

    if [[ "$current_dir" != "$DOTFILES_DIR" ]]; then
        log_message "Error: This script must be run from the correct dotfiles directory: $DOTFILES_DIR" "red"
        log_message "Current location: $current_dir" "yellow"
        log_message "You have four options:" "cyan"
        
        echo ""
        log_message "1. Clone the repository to the correct location:" "cyan"
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo "   git clone $repository_url \"$DOTFILES_DIR\""
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo ""
        
        log_message "2. (Optional) Delete the existing one:" "cyan"
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo "   rm -rf \"$current_dir\""
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo ""
        
        log_message "3. Update 'DOTFILES_DIR' in config.sh to match your current location:" "cyan"
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo "   sed -i 's|^DOTFILES_DIR=.*|DOTFILES_DIR=\"$current_dir\"|' \"$SCRIPT_DIR/config.sh\""
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo ""
        
        log_message "Recommended: Clone to the correct location, delete the existing one, and navigate to it:" "green"
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo "   git clone $repository_url \"$DOTFILES_DIR\" && rm -rf \"$current_dir\" && cd \"$DOTFILES_DIR\" && pwd && ls"
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo ""
        
        log_message "After taking one of these actions, navigate to $DOTFILES_DIR and re-run this script." "green"
        exit 1
    fi
}

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
    "$DOTFILES_DIR/scripts/stow.sh"

    # Execute system-specific configuration script
    #"$DOTFILES_DIR/scripts/configure_system.sh"

    # Try to install packages
    install_packages $setup_install_packages
    
    # Run Timeshift setup
    log_message "Starting $DOTFILES_DIR/scripts/timeshift_setup.sh" "yellow"
    "$DOTFILES_DIR/scripts/timeshift_setup.sh"

    log_message "Setup completed successfully!" "green"
    log_message "Please restart your shell or source your .bashrc for changes to take effect." "yellow"
    log_message "Your original dotfiles have been backed up to $dotfiles_backup_dir" "cyan"
}

# Run the main function if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi