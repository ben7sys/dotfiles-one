#!/bin/bash
## config.sh - Configuration file for setup.sh

## Check if this file is config.sh 
if [ "$(basename "${BASH_SOURCE[0]}")" != "config.sh" ]; then
    log_message "Error: Missing config.sh" "red"
    exit 1
fi

# Check if DOTFILES_DIR is set
if [ -z "${DOTFILES_DIR+x}" ]; then
    log_message "Error: DOTFILES_DIR is not set (source: config.sh)" "red"
    exit 1
fi

## Set DOTFILES_DIR one parent folder based on the location of this file if not already set
if [ -z "${DOTFILES_DIR+x}" ]; then
    DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi
export DOTFILES_DIR


REPO_URL="${REPO_URL:-https://github.com/ben7sys/dotfiles.git}"

# Prevent double sourcing
[ -n "$DOTFILES_CONFIG_SOURCED" ] && return
DOTFILES_CONFIG_SOURCED=1

# Export and set the main directories and files as environment variables
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
export DOTFILES_SCRIPTS="$DOTFILES_DIR/scripts"
export DOTFILES_CONFIG="$SCRIPTS_DIR/config.sh"
export DOTFILES_FUNCTIONS="$SCRIPTS_DIR/functions.sh"
export DOTFILES_LOG="$HOME/dotfiles_setup.log"
export DOTFILES_BACKUP="$HOME/dotfiles_backup"
export DOTFILES_INSTALL_PACKAGES="$SCRIPTS_DIR/install_packages.sh"

# Default theme (Breeze Dark)
DEFAULT_THEME="org.kde.breezedark.desktop"

# Source functions
source "$DOTFILES_FUNCTIONS"
source "$DOTFILES_INSTALL_PACKAGES"

# Additional configurations and variables

# Easy package installation
available_packages="$DOTFILES_DIR/packages.yaml"

# Stow configuration
export stow_source_dir="$DOTFILES_DIR/home"
stow_target_dir="$HOME"

# Package categories by software type
packages_system="base-devel git stow vim zsh htop firewalld python python-pip tmux"
packages_utilities="filelight ranger ripgrep bat exa fd zoxide kcalc keepassxc bitwarden cryptomator timeshift grub-btrfs grsync hardinfo adriconf"
packages_network="nmap tcpdump wireshark-qt remmina openssh"
packages_multimedia="gimp picard vlc haruna spectacle strawberry-qt5"
packages_productivity="obsidian onlyoffice-bin thunderbird"
packages_communication="signal-desktop telegram-desktop discord teamspeak3 whatsapp-nativefier"
packages_browsers="firefox brave-bin vivaldi"
packages_development="docker docker-compose git-lfs visual-studio-code-bin postman-bin nodejs npm go"
packages_gaming="steam lutris-git"
packages_virtualization="qemu virt-manager libvirt"
packages_gui="xorg-server xorg-xinit i3-wm i3status dmenu alacritty polybar"
packages_nvidia="nvidia nvidia-utils nvidia-settings"
packages_office="okular meld"
packages_extras="spotify czkawka-gui anydesk-bin citrix-workspace"
packages_system_utils="fzf jq fastfetch"

# User-defined categories
packages_core="git vim zsh python firefox kcalc fastfetch"
packages_desktop="obsidian visual-studio-code-bin keepassxc cryptomator kcalc signal-desktop okular spectacle meld thunderbird"
packages_dev="$packages_development $packages_virtualization git python python-pip"
packages_fullhome="$packages_core $packages_desktop $packages_utilities $packages_network $packages_multimedia $packages_productivity $packages_communication $packages_browsers $packages_office $packages_system_utils $packages_gui"
packages_fullwork="$packages_fullhome $packages_dev $packages_virtualization remmina citrix-workspace anydesk-bin"
packages_fullgaming="$packages_fullhome $packages_gaming $packages_nvidia"

# Packages to be installed (space-separated list of package sets or individual packages)
setup_install_packages="$packages_core"
