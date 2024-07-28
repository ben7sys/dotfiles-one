#!/bin/bash

# Set the source directory to the parent of the scripts directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Function to stow files
stow_files() {
    local target_dir="$1"
    local stow_dir="$2"
    echo "Stowing $stow_dir to $target_dir"
    stow -v -R -t "$target_dir" -d "$DOTFILES_DIR" "$stow_dir"
}

# Stow home directory files
stow_files "$HOME" "home"

# Stow system files if running as root
if [ "$EUID" -eq 0 ]; then
    stow_files "/" "system"
else
    echo "Not running as root. Skipping system files."
fi

# Handle .config directory separately
if [ -d "$DOTFILES_DIR/home/.config" ]; then
    echo "Stowing .config directory..."
    stow -v -R -t "$HOME/.config" -d "$DOTFILES_DIR/home" ".config"
fi

echo "Stowing complete!"

# Note: This script does not handle mounts. Use the separate mount.sh script for that.