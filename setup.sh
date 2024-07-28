#!/bin/bash

# setup.sh: Automate system setup and dotfiles installation for multiple operating systems

set -euo pipefail

# Function to ensure correct directory
ensure_correct_directory() {
    local current_dir=$(pwd)
    local repo_name=$(basename "$current_dir")
    local desired_dir="$HOME/.dotfiles"

    if [[ "$repo_name" != ".dotfiles" ]]; then
        if [[ "$current_dir" != "$desired_dir" ]]; then
            log_message "Moving repository to $desired_dir..." "yellow"
            mv "$current_dir" "$desired_dir"
            cd "$desired_dir"
            log_message "Repository moved successfully. Re-run this script from the new location." "green"
            exit 0
        fi
    fi
}

# Source common functions and system configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/common_functions.sh"
source "$SCRIPT_DIR/scripts/configure_system.sh"

# Main directories
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup"

# Main function to orchestrate the setup
main() {
    ensure_correct_directory

    local os=$(check_os)
    log_message "Starting setup process for $os..." "green"
    
    check_not_root
    check_requirements
    backup_dotfiles "$DOTFILES_DIR" "$BACKUP_DIR"
    
    "$DOTFILES_DIR/scripts/install_packages.sh" "$DOTFILES_DIR/packages_arch.json" core extended
    
    stow_dotfiles "$DOTFILES_DIR" "$HOME" "home"
    configure_system
    setup_user_env
    
    log_message "Setup completed successfully!" "green"
    log_message "Please restart your shell or source your .bashrc for changes to take effect." "yellow"
}

# Run the main function
main