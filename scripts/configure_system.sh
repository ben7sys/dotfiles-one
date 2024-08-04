#!/bin/bash

# configure_system.sh: System-specific configurations

# Determine the script's directory and the parent directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

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

# Use SCRIPT_DIR to source the config.sh file from the same directory or a parent directory
source_file_if_not_sourced "$PARENT_DIR/config.sh"

# Function to configure system settings
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