#!/bin/bash
## config.sh - Configuration file for setup.sh
## setup.sh: Automate system setup and dotfiles installation for multiple operating systems

## Repository URL
repository_url=https://github.com/ben7sys/dotfiles.git

# Main directories and files
dotfiles_dir="$HOME/.dotfiles"
dotfiles_backup_dir="$HOME/dotfiles_backup"
dotfiles_log_file="$HOME/dotfiles_setup.log"

# Easy package installation
# for setup.sh
# usable as alias: "install [package]"

# Packages available to install: 
available_packages="$dotfiles_dir/packages.yaml"

# Set of packages
packages_core="base-devel git stow vim zsh htop"
packages_desktop="obsidian crytomator spotify"
packages_developer="code"

# Packages to be installed (space-separated list of package sets or individual packages)
setup_install_packages="$packages_core $packages_desktop $packages_developer" 

# Stow configuration
stow_source_dir="$dotfiles_dir/home"
stow_target_dir="$HOME"

# Additional configuration options can be added here
            
