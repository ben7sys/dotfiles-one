#!/bin/bash

# setup.sh: Automate system setup and dotfiles installation for Arch and Debian-based systems

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Main directories
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup"

# Log file
LOG_FILE="$HOME/setup_log.txt"

# Function to log messages
log_message() {
    echo -e "${2:-$NC}$1${NC}"
    echo "$(date): $1" >> "$LOG_FILE"
}

# Function to detect the package manager
detect_package_manager() {
    if command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v apt-get &> /dev/null; then
        echo "apt"
    else
        log_message "Unsupported package manager" "${RED}"
        exit 1
    fi
}

# Function to install packages
install_packages() {
    local pkg_manager=$(detect_package_manager)
    log_message "Installing packages using $pkg_manager..."
    
    case $pkg_manager in
        pacman)
            sudo pacman -Syu --noconfirm
            sudo pacman -S --needed --noconfirm - < "$DOTFILES_DIR/install/packages_arch.txt"
            ;;
        apt)
            sudo apt-get update
            sudo apt-get upgrade -y
            sudo apt-get install -y $(cat "$DOTFILES_DIR/install/packages_debian.txt")
            ;;
    esac
}

# Function to check system requirements
check_requirements() {
    log_message "Checking system requirements..."
    local pkg_manager=$(detect_package_manager)
    
    case $pkg_manager in
        pacman)
            command -v git >/dev/null 2>&1 || sudo pacman -S --noconfirm git
            command -v stow >/dev/null 2>&1 || sudo pacman -S --noconfirm stow
            ;;
        apt)
            command -v git >/dev/null 2>&1 || sudo apt-get install -y git
            command -v stow >/dev/null 2>&1 || sudo apt-get install -y stow
            ;;
    esac
}

# Function to backup existing dotfiles
backup_dotfiles() {
    log_message "Backing up existing dotfiles..."
    mkdir -p "$BACKUP_DIR"
    for file in "$DOTFILES_DIR"/home/.*; do
        [ -e "$HOME/$(basename "$file")" ] && mv "$HOME/$(basename "$file")" "$BACKUP_DIR/"
    done
}

# Function to stow dotfiles
stow_dotfiles() {
    log_message "Stowing dotfiles..."
    cd "$DOTFILES_DIR" && stow -v -R -t "$HOME" home
}

# Function to configure system settings
configure_system() {
    log_message "Configuring system settings..."
    local pkg_manager=$(detect_package_manager)
    
    case $pkg_manager in
        pacman)
            # Arch-specific configurations
            sudo systemctl enable firewalld
            sudo systemctl start firewalld
            ;;
        apt)
            # Debian-specific configurations
            sudo ufw enable
            ;;
    esac
}

# Function to set up user environment
setup_user_env() {
    log_message "Setting up user environment..."
    # Add user-specific setup commands here
    # Example: setting up Python virtual environment
    python3 -m venv "$HOME/.venv"
}

# Main function to orchestrate the setup
main() {
    log_message "Starting setup process..." "${GREEN}"
    
    check_requirements
    backup_dotfiles
    install_packages
    stow_dotfiles
    configure_system
    setup_user_env
    
    log_message "Setup completed successfully!" "${GREEN}"
}

# Run the main function
main