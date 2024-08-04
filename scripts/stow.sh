#!/bin/bash

# Prevent duplicate sourcing for any file
source_file_if_not_sourced() {
    local file_path="$1"
    local file_var_name="SOURCED_${file_path//[^a-zA-Z0-9_]/_}"
    if [ -f "$file_path" ]; then
        if [ -z "${!file_var_name}" ]; then
            source "$file_path"
            export "$file_var_name"=1
        fi
    else
        echo "Error: $file_path not found." >&2
        exit 1
    fi
}

# Source necessary files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source_file_if_not_sourced "$ROOT_DIR/config.sh"

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

