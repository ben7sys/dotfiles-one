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

# Function to check system requirements
check_requirements() {
    log_message "Checking system requirements..." "yellow"
    command -v git >/dev/null 2>&1 || sudo pacman -S --noconfirm git
    command -v stow >/dev/null 2>&1 || sudo pacman -S --noconfirm stow
}

# Improved function to backup existing dotfiles
backup_dotfiles() {
    local dotfiles_dir="$1"
    local backup_dir="$2"
    
    log_message "Backing up existing dotfiles..." "yellow"
    mkdir -p "$backup_dir"
    
    # First, handle hidden files and directories
    for file in "$dotfiles_dir"/home/.*; do
        base_name=$(basename "$file")
        if [ -e "$HOME/$base_name" ] && [ ! -L "$HOME/$base_name" ]; then
            mv "$HOME/$base_name" "$backup_dir/"
            log_message "Backed up $base_name" "cyan"
        fi
    done
    
    # Then, handle non-hidden files and directories
    for file in "$dotfiles_dir"/home/*; do
        base_name=$(basename "$file")
        if [ -e "$HOME/$base_name" ] && [ ! -L "$HOME/$base_name" ]; then
            mv "$HOME/$base_name" "$backup_dir/"
            log_message "Backed up $base_name" "cyan"
        fi
    done
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
export -f color_text log_message check_requirements backup_dotfiles \
           check_root check_not_root confirm command_exists \
           ensure_dir_exists symlink_file install_aur_helper check_os setup_user_env