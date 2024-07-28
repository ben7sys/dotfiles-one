#!/bin/bash

# setup.sh: Automate system setup and dotfiles installation for multiple operating systems

set -euo pipefail

# Source common functions and system configuration
source "$(dirname "$0")/scripts/common_functions.sh"
source "$(dirname "$0")/scripts/configure_system.sh"

# Main directories
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup"

# Function to ensure the repository is in the correct location
ensure_correct_location() {
    local current_dir=$(pwd)
    local desired_dir="$HOME/.dotfiles"

    if [[ "$current_dir" != "$desired_dir" ]]; then
        log_message "Error: This script must be run from $desired_dir" "red"
        log_message "Current location: $current_dir" "yellow"
        
        if [[ -d "$desired_dir" ]]; then
            log_message "Error: The directory $desired_dir already exists." "red"
            log_message "Please resolve any conflicts manually and ensure you're running the script from the correct location." "yellow"
            # implement a backup function later
        else
            log_message "The dotfiles directory doesn't exist at the correct location." "yellow"
            log_message "You have two options:" "cyan"
            echo "1. Move the current directory to the correct location:"
            echo "   mv \"$current_dir\" \"$desired_dir\""
            echo
            echo "2. If this isn't the dotfiles repository, clone it to the correct location:"
            echo "   git clone <repository_url> \"$desired_dir\""
            log_message "After taking one of these actions, navigate to $desired_dir and re-run this script." "green"
        fi
        
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
    
    if ! "$DOTFILES_DIR/scripts/install_packages.sh" "$DOTFILES_DIR/bootstrap/packages_arch.json" core extended; then
        log_message "Failed to install packages. Exiting." "red"
        exit 1
    fi
    
    stow_dotfiles "$DOTFILES_DIR" "$HOME" "home" "$BACKUP_DIR"
    configure_system
    setup_user_env
    
    log_message "Setup completed successfully!" "green"
    log_message "Please restart your shell or source your .bashrc for changes to take effect." "yellow"
    log_message "Your original dotfiles have been backed up to $BACKUP_DIR" "cyan"
}

# Run the main function
main