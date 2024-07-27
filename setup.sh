#!/bin/bash

# Main setup script for dotfiles

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source helper functions
source "$DOTFILES_DIR/scripts/utils.sh"

# Check if not running as root
check_not_root

# Install base packages
"$DOTFILES_DIR/scripts/install_packages.sh"

# Stow dotfiles
"$DOTFILES_DIR/scripts/stow.sh"

# Set up system configurations
"$DOTFILES_DIR/scripts/configure_system.sh"

echo "Setup complete. Please restart your session to apply all changes."