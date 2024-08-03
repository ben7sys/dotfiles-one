#!/bin/bash

# Main directories and files
dotfiles_dir="$HOME/.dotfiles"
dotfiles_backup_dir="$HOME/dotfiles_backup"
dotfiles_log_file="$HOME/dotfiles_setup.log"

# Packages to be installed
# Packages available to install: 
setup_install_packages="core desktop"

# Stow configuration
stow_source_dir="$dotfiles_dir/home"
stow_target_dir="$HOME"

# Additional configuration options can be added here
