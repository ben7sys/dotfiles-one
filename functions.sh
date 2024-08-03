#!/bin/bash

# common_functions.sh: Arch-specific reusable functions for dotfiles management scripts

# Determine the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the config file
source "$SCRIPT_DIR/config.sh"

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
    echo "$(date): $message" >> "$dotfiles_log_file"
}

# Function to check system requirements
check_requirements() {
    log_message "Checking system requirements..." "yellow"
    command -v git >/dev/null 2>&1 || sudo pacman -S --noconfirm git
    command -v stow >/dev/null 2>&1 || sudo pacman -S --noconfirm stow
}

# Backup existing dotfiles
backup_dotfiles() {
    local source_dir="$stow_source_dir"
    local files_backed_up=0
    
    log_message "Backing up existing dotfiles..." "yellow"
    
    # Check if source directory exists
    if [ ! -d "$source_dir" ]; then
        log_message "Error: Source directory $source_dir does not exist." "red"
        return 1
    fi
    
    # Ensure backup directory exists
    ensure_dir_exists "$dotfiles_backup_dir"
    
    # Function to handle backup of a single file
    backup_file() {
        local file="$1"
        local base_name=$(basename "$file")
        
        # Skip . and .. directories
        if [[ "$base_name" == "." || "$base_name" == ".." ]]; then
            return
        fi
        
        if [ -e "$stow_target_dir/$base_name" ] && [ ! -L "$stow_target_dir/$base_name" ]; then
            if mv "$stow_target_dir/$base_name" "$dotfiles_backup_dir/"; then
                log_message "Backed up $base_name" "cyan"
                ((files_backed_up++))
            else
                log_message "Failed to backup $base_name" "red"
            fi
        fi
    }
    
    # Handle hidden files and directories
    for file in "$source_dir"/.*; do
        backup_file "$file"
    done
    
    # Handle non-hidden files and directories
    for file in "$source_dir"/*; do
        backup_file "$file"
    done
    
    if [ $files_backed_up -eq 0 ]; then
        log_message "No files needed backup." "green"
    else
        log_message "Backed up $files_backed_up files to $dotfiles_backup_dir" "green"
    fi
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