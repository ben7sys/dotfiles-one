#!/bin/bash

# common_functions.sh: Arch-specific reusable functions for dotfiles management scripts

# Log file
LOG_FILE="$HOME/dotfiles_setup.log"

# Function for color formatting
color_text() {
  case $1 in
    green)
      echo -e "\e[32m$2\e[0m"
      ;;
    yellow)
      echo -e "\e[33m$2\e[0m"
      ;;
    red)
      echo -e "\e[31m$2\e[0m"
      ;;
    blue)
      echo -e "\e[34m$2\e[0m"
      ;;
    cyan)
      echo -e "\e[36m$2\e[0m"
      ;;
    magenta)
      echo -e "\e[35m$2\e[0m"
      ;;
    *)
      echo "$2"
      ;;
  esac
}

# Function to log messages
log_message() {
    local message="$1"
    local color="${2:-normal}"
    color_text "$color" "$message"
    echo "$(date): $message" >> "$LOG_FILE"
}

install_packages() {
    local json_file="$1"
    shift
    local modules=("$@")

    if [ ! -f "$json_file" ]; then
        log_message "Package JSON file not found: $json_file" "red"
        return 1
    fi

    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        log_message "jq is required but not installed. Installing jq..." "yellow"
        sudo pacman -S --noconfirm jq
    fi

    # Update the system first
    log_message "Updating system packages..." "yellow"
    sudo pacman -Syu --noconfirm

    for module in "${modules[@]}"; do
        log_message "Installing packages for module: $module" "yellow"
        
        # Install pacman packages
        pacman_packages=$(jq -r ".$module.pacman[]" "$json_file")
        if [ -n "$pacman_packages" ]; then
            log_message "Installing pacman packages for $module..." "cyan"
            echo "$pacman_packages" | sudo pacman -S --needed --noconfirm -
        fi

        # Install yay packages
        yay_packages=$(jq -r ".$module.yay[]" "$json_file")
        if [ -n "$yay_packages" ]; then
            if ! command -v yay &> /dev/null; then
                log_message "yay is required but not installed. Installing yay..." "yellow"
                install_aur_helper
            fi
            log_message "Installing yay packages for $module..." "magenta"
            echo "$yay_packages" | yay -S --needed --noconfirm -
        fi
    done
}

# Example usage:
# install_packages "packages_arch.json" "core" "extended" "gui"

# Function to check system requirements
check_requirements() {
    log_message "Checking system requirements..." "yellow"
    command -v git >/dev/null 2>&1 || sudo pacman -S --noconfirm git
    command -v stow >/dev/null 2>&1 || sudo pacman -S --noconfirm stow
}

# Function to backup existing dotfiles
backup_dotfiles() {
    local dotfiles_dir="$1"
    local backup_dir="$2"
    
    log_message "Backing up existing dotfiles..." "yellow"
    mkdir -p "$backup_dir"
    for file in "$dotfiles_dir"/home/.*; do
        [ -e "$HOME/$(basename "$file")" ] && mv "$HOME/$(basename "$file")" "$backup_dir/"
    done
}

# Function to stow dotfiles
stow_dotfiles() {
    local dotfiles_dir="$1"
    local target_dir="$2"
    local stow_dir="$3"
    
    log_message "Stowing $stow_dir to $target_dir" "yellow"
    stow -v -R -t "$target_dir" -d "$dotfiles_dir" "$stow_dir"
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# Function to check if not running as root
check_not_root() {
    if [ "$EUID" -ne 0 ]; then
        return 0
    else
        log_message "This script should not be run as root" "red"
        return 1
    fi
}

# Function to prompt for confirmation
confirm() {
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to create a directory if it doesn't exist
ensure_dir_exists() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
    fi
}

# Function to symlink a file
symlink_file() {
    local source="$1"
    local target="$2"
    if [ -e "$target" ]; then
        log_message "Backing up existing $target" "yellow"
        mv "$target" "${target}.bak"
    fi
    ln -s "$source" "$target"
    log_message "Symlinked $source to $target" "green"
}

# Function to install AUR helper (yay)
install_aur_helper() {
    if ! command_exists yay; then
        log_message "Installing AUR helper (yay)..." "yellow"
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        (cd /tmp/yay && makepkg -si --noconfirm)
        rm -rf /tmp/yay
    else
        log_message "AUR helper (yay) is already installed" "green"
    fi
}

# Function to check the operating system
check_os() {
    case "$(uname -s)" in
        Linux*)
            if [ -f "/etc/arch-release" ]; then
                echo "arch"
            elif [ -f "/etc/debian_version" ]; then
                echo "debian"
            elif [ -f "/etc/fedora-release" ]; then
                echo "fedora"
            else
                echo "unknown"
            fi
            ;;
        Darwin*)    
            echo "macos"
            ;;
        *)          
            echo "unknown"
            ;;
    esac
}

# Function to set up user environment
setup_user_env() {
    log_message "Setting up user environment..." "yellow"
    
    # Create Python virtual environment
    python3 -m venv "$HOME/.venv"
    
    # Check if venv_info function already exists in .bashrc
    if ! grep -q "venv_info()" "$HOME/.bashrc"; then
        echo '
# Python virtual environment function
venv_info() {
    [ -n "$VIRTUAL_ENV" ] && echo " ($(basename $VIRTUAL_ENV))"
}
' >> "$HOME/.bashrc"
    fi
    
    # Add activation of venv to .bashrc if not already present
    if ! grep -q "source \"\$HOME/.venv/bin/activate\"" "$HOME/.bashrc"; then
        echo 'source "$HOME/.venv/bin/activate"' >> "$HOME/.bashrc"
    fi
    
    log_message "Python virtual environment created and .bashrc updated" "green"
}

# Export all functions
export -f color_text log_message install_packages check_requirements backup_dotfiles \
           stow_dotfiles check_root check_not_root confirm command_exists \
           ensure_dir_exists symlink_file install_aur_helper check_os setup_user_env