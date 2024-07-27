#!/bin/bash

# Install necessary packages

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Install base packages
sudo pacman -Syu --needed - < "$DOTFILES_DIR/install/base.txt"

# Optionally install development packages
if [ "$1" = "dev" ] || [ "$1" = "all" ]; then
    sudo pacman -S --needed - < "$DOTFILES_DIR/install/dev.txt"
fi

# Optionally install GUI packages
if [ "$1" = "gui" ] || [ "$1" = "all" ]; then
    sudo pacman -S --needed - < "$DOTFILES_DIR/install/gui.txt"
fi

# Install AUR helper (yay)
if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
fi

# Install AUR packages if specified
if [ -f "$DOTFILES_DIR/install/aur.txt" ]; then
    yay -S --needed - < "$DOTFILES_DIR/install/aur.txt"
fi