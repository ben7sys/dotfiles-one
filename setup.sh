#!/bin/bash

# setup.sh: Automate system setup and dotfiles installation for multiple operating systems

set -euo pipefail

# Determine the directory of the setup script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the config file
if [ -f "$SCRIPT_DIR/config.sh" ]; then
    source "$SCRIPT_DIR/config.sh"
else
    echo "Error: config.sh not found in $SCRIPT_DIR" >&2
    exit 1
fi

# Source functions.sh
if [ -f "$dotfiles_dir/functions.sh" ]; then
    source "$dotfiles_dir/functions.sh"
else
    echo "Error: functions.sh not found in $dotfiles_dir" >&2
    exit 1
fi

# Ensure the script is run from the correct dotfiles directory
ensure_correct_location() {
    local current_dir=$(pwd)

    if [[ "$current_dir" != "$dotfiles_dir" ]]; then
        log_message "Error: This script must be run from the dotfiles directory: $dotfiles_dir" "red"
        log_message "Current location: $current_dir" "yellow"
        log_message "You have two options:" "cyan"
        echo "1. Clone the repository to the correct location:"
        echo "   git clone <repository_url> \"$dotfiles_dir\""
        echo "2. If you've already cloned it elsewhere, update 'dotfiles_dir' in config.sh"
        log_message "After taking one of these actions, navigate to $dotfiles_dir and re-run this script." "green"
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
    
    local packages_file="$dotfiles_dir/packages_$os.yaml"
    if [ ! -f "$packages_file" ]; then
        log_message "Error: Package file $packages_file not found." "red"
        exit 1
    fi

    if ! "$dotfiles_dir/scripts/install_packages.sh" "$packages_file" $setup_install_packages; then
        log_message "Failed to install packages. Exiting." "red"
        exit 1
    fi
    
    "$dotfiles_dir/scripts/stow.sh"
    #"$dotfiles_dir/scripts/configure_system.sh"
    setup_user_env
    
    log_message "Setup completed successfully!" "green"
    log_message "Please restart your shell or source your .bashrc for changes to take effect." "yellow"
    log_message "Your original dotfiles have been backed up to $dotfiles_backup_dir" "cyan"
}

# Run the main function if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi