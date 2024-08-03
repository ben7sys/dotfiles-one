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

# Stow configuration
stow_source_dir="$dotfiles_dir/home"
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


# User-defined categories
packages_core="firefox kcalc python base-devel git stow vim zsh htop fastfetch firewalld python-pip fzf jq"
packages_desktop="obsidian visual-studio-code-bin keepassxc cryptomator kcalc thunderbird signal-desktop telegram-desktop okular openssh spectacle haruna meld"
packages_dev="$packages_development $packages_virtualization git python python-pip nodejs npm docker docker-compose"
packages_fullhome="$packages_core $packages_desktop $packages_utilities $packages_network $packages_multimedia $packages_productivity $packages_communication $packages_browsers $packages_office $packages_extras"
packages_fullwork="$packages_fullhome $packages_dev $packages_virtualization remmina citrix-workspace anydesk-bin"
packages_fullgaming="$packages_fullhome $packages_gaming $packages_nvidia"

# Packages to be installed (space-separated list of package sets or individual packages)
setup_install_packages="$packages_core $packages_desktop"
