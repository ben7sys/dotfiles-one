#!/bin/bash

# configure_system.sh: System-specific configurations

## --- Source files ---
## Prevent duplicate sourcing for any file
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

## Source necessary files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source_file_if_not_sourced "$DOTFILES_ROOT_DIR/config.sh"

configure_system() {
    local os=$(check_os)
    
    log_message "Configuring system settings for $os..." "yellow"
    
    case $os in
        arch)
            # Arch-specific configurations
            sudo systemctl enable firewalld
            sudo systemctl start firewalld
            # Add more Arch-specific configurations here
            ;;
        debian)
            # Debian-specific configurations
            sudo ufw enable
            # Add more Debian-specific configurations here
            ;;
        fedora)
            # Fedora-specific configurations
            sudo systemctl enable firewalld
            sudo systemctl start firewalld
            # Add more Fedora-specific configurations here
            ;;
        macos)
            # macOS-specific configurations
            # Example: Enable built-in firewall
            /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
            # Add more macOS-specific configurations here
            ;;
        *)
            log_message "Unsupported operating system for automatic configuration" "red"
            ;;
    esac
    
    log_message "System configuration completed" "green"
}

# Run the configuration if this script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    configure_system
fi