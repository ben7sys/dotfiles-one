#!/bin/bash

# Determine the directory of the setup script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the config file
source "$SCRIPT_DIR/config.sh"

# Source other files
source "$dotfiles_dir/functions.sh"

# Function to stow files
stow_files() {
    log_message "Stowing files from $stow_source_dir to $stow_target_dir"
    stow -v -R -t "$stow_target_dir" -d "$(dirname "$stow_source_dir")" "$(basename "$stow_source_dir")"
}

# Main function
main() {
    # Check if stow is installed
    if ! command -v stow &> /dev/null; then
        log_message "Error: stow is not installed. Please install it first." "red"
        exit 1
    fi

    # Check if source directory exists
    if [ ! -d "$stow_source_dir" ]; then
        log_message "Error: Source directory $stow_source_dir does not exist." "red"
        exit 1
    fi

    # Perform stow operation
    stow_files

    # Handle .config directory separately if needed
    if [ -d "$stow_source_dir/.config" ]; then
        log_message "Stowing .config directory..."
        stow -v -R -t "$stow_target_dir/.config" -d "$stow_source_dir" ".config"
    fi

    log_message "Stowing completed successfully!" "green"
}

# Run main function
main