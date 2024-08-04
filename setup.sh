#!/bin/bash

# setup.sh: Automate system setup and dotfiles installation for multiple operating systems

## --- Source files ---
## Prevent duplicate sourcing for any file
source_file_if_not_sourced() {
    local file_path="$1"
    local file_var_name="SOURCED_${file_path//[^a-zA-Z0-9_]/_}"
    
    if [ -f "$file_path" ]; then
        # Verwenden von `declare -n` für die indirekte Variablenreferenz
        declare -n file_var_ref="$file_var_name"
        if [ -z "$file_var_ref" ]; then
            source "$file_path"
            file_var_ref=1
        fi
    else
        echo "Error: $file_path not found." >&2
        exit 1
    fi
}

# Determine the script's directory and the parent directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Use SCRIPT_DIR to source the config.sh file from the same directory or a parent directory
source_file_if_not_sourced "$SCRIPT_DIR/config.sh"
echo "setup.sh: DOTFILES_DIR: $DOTFILES_DIR"
echo "setup.sh: stow_source_dir: $stow_source_dir"

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
    "$DOTFILES_DIR/scripts/timeshift_setup.sh"

    log_message "Setup completed successfully!" "green"
    log_message "Please restart your shell or source your .bashrc for changes to take effect." "yellow"
    log_message "Your original dotfiles have been backed up to $dotfiles_backup_dir" "cyan"
}

# Run the main function if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi