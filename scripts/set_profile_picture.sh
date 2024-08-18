#!/bin/bash

# Source configuration and functions
source "$DOTFILES_DIR/scripts/config.sh"
source "$DOTFILES_DIR/scripts/functions.sh"

# Set profile picture
set_profile_picture() {
    log_message "Setting profile picture..." "yellow"

    # Supported file extensions
    local supported_extensions=("png" "jpg" "jpeg" "svg")
    local face_file=""

    # Check for face file with supported extensions
    for ext in "${supported_extensions[@]}"; do
        if [[ -f "$DOTFILES_USER/face.$ext" ]]; then
            face_file="$DOTFILES_USER/face.$ext"
            break
        fi
    done

    # If no face file found, exit
    if [[ -z "$face_file" ]]; then
        log_message "No supported face file found in $DOTFILES_USER" "red"
        return 1
    fi

    # Set profile picture using KDE's user manager
    if command_exists kcmshell5; then
        log_message "Setting profile picture using KDE User Manager..." "cyan"
        kcmshell5 kcm_users --set-face "$face_file"
        log_message "Profile picture set successfully" "green"
    else
        log_message "KDE User Manager not found. Unable to set profile picture." "red"
        return 1
    fi
}

# Main function
main() {
    check_not_root
    set_profile_picture
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi