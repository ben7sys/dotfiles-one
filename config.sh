#!/bin/bash
## config.sh - Configuration file for setup.sh

# Determine the script's directory and the parent directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

### --- Source files ---
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

# Source the config.sh file from the parent directory
source_file_if_not_sourced "$SCRIPT_DIR/config.sh"
source_file_if_not_sourced "$SCRIPT_DIR/functions.sh"
source_file_if_not_sourced "$SCRIPT_DIR/scripts/install_packages.sh"

# Export and set the main directories and files as environment variables
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
export DOTFILES_BACKUP_DIR="$HOME/dotfiles_backup"
export DOTFILES_LOG_FILE="$HOME/dotfiles_setup.log"
export DOTFILES_FUNCTIONS="$DOTFILES_DIR/functions.sh"
export DOTFILES_CONFIG="$DOTFILES_DIR/config.sh"
export DOTFILES_INSTALL_PACKAGES="$DOTFILES_DIR/scripts/install_packages.sh"

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
