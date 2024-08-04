#!/bin/bash

# setup.sh: Automate system setup and dotfiles installation for multiple operating systems

set -euo pipefail

## --- Source files ---
## Prevent duplicate sourcing for any file
source_file_if_not_sourced() {
    local file_path="$1"
    local file_var_name="SOURCED_${file_path//[^a-zA-Z0-9_]/_}"
    # eval is used to access the value of a dynamically named variable
    if [ -f "$file_path" ]; then
        if [ -z "$(eval echo \${$file_var_name})" ]; then
            source "$file_path"
            export "$file_var_name"=1
        fi
    else
        echo "Error: $file_path not found." >&2
        exit 1
    fi
}

# Determine the script's directory and the parent directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source the config.sh file from the parent directory
source_file_if_not_sourced "$SCRIPT_DIR/config.sh"

# Ensure the script is in the coreect location
ensure_correct_location() {
    local current_dir=$(pwd)

    if [[ "$current_dir" != "$dotfiles_dir" ]]; then
        log_message "Error: This script must be run from the correct dotfiles directory: $dotfiles_dir" "red"
        log_message "Current location: $current_dir" "yellow"
        log_message "You have four options:" "cyan"
        
        echo ""
        log_message "1. Clone the repository to the correct location:" "cyan"
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo "   git clone $repository_url \"$dotfiles_dir\""
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo ""
        
        log_message "2. (Optional) Delete the existing one:" "cyan"
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo "   rm -rf \"$current_dir\""
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo ""
        
        log_message "3. Update 'dotfiles_dir' in config.sh to match your current location:" "cyan"
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo "   sed -i 's|^dotfiles_dir=.*|dotfiles_dir=\"$current_dir\"|' \"$SCRIPT_DIR/config.sh\""
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo ""
        
        log_message "Recommended: Clone to the correct location, delete the existing one, and navigate to it:" "green"
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo "   git clone $repository_url \"$dotfiles_dir\" && rm -rf \"$current_dir\" && cd \"$dotfiles_dir\" && pwd && ls"
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo ""
        
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
    
    log_message "Trying to backup the existing dotfiles" "yellow"
    # Backup existing dotfiles before proceeding
    backup_dotfiles

    log_message "Trying to stow the dotfiles" "yellow"
    # Stow the dotfiles   
    "$dotfiles_dir/scripts/stow.sh"

    # Execute system-specific configuration script
    #"$dotfiles_dir/scripts/configure_system.sh"

    # Try to install packages
    install_packages $setup_install_packages
    
    # Run Timeshift setup
    if [ "$os" = "arch" ]; then  # Assuming this is for Arch Linux only
        log_message "Setting up Timeshift..." "yellow"
        if check_root; then
            "$dotfiles_dir/scripts/timeshift_setup.sh"
        else
            log_message "Root privileges required for Timeshift setup. Please run the script with sudo." "red"
            log_message "You can run it manually later with: sudo $dotfiles_dir/scripts/timeshift_setup.sh" "yellow"
        fi
    fi

    log_message "Setup completed successfully!" "green"
    log_message "Please restart your shell or source your .bashrc for changes to take effect." "yellow"
    log_message "Your original dotfiles have been backed up to $dotfiles_backup_dir" "cyan"
}

# Run the main function if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi