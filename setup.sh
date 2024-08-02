#!/bin/bash

# setup.sh: Automate system setup and dotfiles installation for multiple operating systems

set -euo pipefail

# Determine the directory of the setup script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the config file
source "$SCRIPT_DIR/config.sh"

# Source other files
source "$dotfiles_dir/functions.sh"

# Ensure the repository is in the correct location
ensure_correct_location() {
    local current_dir=$(pwd)

    if [[ "$current_dir" != "$dotfiles_dir" ]]; then
        log_message "Error: This script must be run from $dotfiles_dir" "red"
        log_message "Current location: $current_dir" "yellow"
        
        if [[ -d "$dotfiles_dir" ]]; then
            log_message "Error: The directory $dotfiles_dir already exists." "red"
            log_message "Please resolve any conflicts manually and ensure you're running the script from the correct location." "yellow"
        else
            log_message "The dotfiles directory doesn't exist at the correct location." "yellow"
            log_message "You have two options:" "cyan"
            echo "1. Move the current directory to the correct location:"
            echo "   mv \"$current_dir\" \"$dotfiles_dir\""
            echo
            echo "2. If this isn't the dotfiles repository, clone it to the correct location:"
            echo "   git clone <repository_url> \"$dotfiles_dir\""
            log_message "After taking one of these actions, navigate to $dotfiles_dir and re-run this script." "green"
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
    
    local packages_file="$dotfiles_root/packages_$os.yaml"
    if [ ! -f "$packages_file" ]; then
        log_message "Error: Package file $packages_file not found." "red"
        exit 1
    fi

    if ! "$dotfiles_root/scripts/install_packages.sh" "$packages_file" $setup_install_packages; then
        log_message "Failed to install packages. Exiting." "red"
        exit 1
    fi
    
    "$dotfiles_root/scripts/stow.sh"
    #"$dotfiles_root/scripts/configure_system.sh"
    setup_user_env
    
    log_message "Setup completed successfully!" "green"
    log_message "Please restart your shell or source your .bashrc for changes to take effect." "yellow"
    log_message "Your original dotfiles have been backed up to $dotfiles_backup_dir" "cyan"
}

# Run the main function if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi