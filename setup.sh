#!/bin/bash

# setup.sh: Automate system setup and dotfiles installation for Arch Linux

set -euo pipefail

# Source common functions
source "$(dirname "$0")/common_functions.sh"

# Main directories
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup"

# Function to configure system settings
configure_system() {
    log_message "Configuring system settings..." "yellow"
    sudo systemctl enable firewalld
    sudo systemctl start firewalld
}

# Function to set up user environment
setup_user_env() {
    log_message "Setting up user environment..." "yellow"
    # Add user-specific setup commands here
    # Example: setting up Python virtual environment
    python3 -m venv "$HOME/.venv"
}

# Main function to orchestrate the setup
main() {
    log_message "Starting setup process for Arch Linux..." "green"
    
    check_not_root
    check_requirements
    backup_dotfiles "$DOTFILES_DIR" "$BACKUP_DIR"
    install_packages "$DOTFILES_DIR/install/packages.txt"
    install_aur_helper
    stow_dotfiles "$DOTFILES_DIR" "$HOME" "home"
    configure_system
    setup_user_env
    
    log_message "Setup completed successfully!" "green"
}

# Run the main function
main