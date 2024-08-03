#!/bin/bash
## config.sh - Configuration file for setup.sh
## setup.sh: Automate system setup and dotfiles installation for multiple operating systems

## Repository URL
repository_url=https://github.com/ben7sys/dotfiles.git

# Main directories and files
dotfiles_dir="$HOME/.dotfiles"
dotfiles_backup_dir="$HOME/dotfiles_backup"
dotfiles_log_file="$HOME/dotfiles_setup.log"

# Packages to be installed
# Packages available to install: 
setup_install_packages="core desktop work"

# Stow configuration
stow_source_dir="$dotfiles_dir/home"
stow_target_dir="$HOME"

# Additional configuration options can be added here
