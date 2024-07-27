#!/bin/bash

# configure_system.sh: System-specific configurations

# Source common functions
source "$(dirname "$0")/common_functions.sh"

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