#!/bin/bash

# common_functions.sh: Arch-specific reusable functions for dotfiles management scripts

# Determine the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the config file
source "$SCRIPT_DIR/config.sh"

# Function for color formatting
color_text() {
  local color_code=""
  case $1 in
    green) color_code="\e[32m";;
    yellow) color_code="\e[33m";;
    red) color_code="\e[31m";;
    blue) color_code="\e[34m";;
    cyan) color_code="\e[36m";;
    magenta) color_code="\e[35m";;
    *) color_code="";;
  esac
  echo -e "${color_code}$2\e[0m"
}

# Function to log messages
log_message() {
    local message="$1"
    local color="${2:-normal}"
    local level="${3:-INFO}"
    color_text "$color" "[$level] $message"
    echo "$(date): [$level] $message" >> "$dotfiles_log_file"
}

# Function to check system requirements
check_requirements() {
    log_message "Checking system requirements..." "yellow"
    command -v git >/dev/null 2>&1 || sudo pacman -S --noconfirm git
    command -v stow >/dev/null 2>&1 || sudo pacman -S --noconfirm stow
}

# Function to backup existing dotfiles
backup_dotfiles() {
    log_message "Backing up existing dotfiles..." "yellow"
    
    # Ensure backup directory exists
    mkdir -p "$dotfiles_backup_dir"
    
    # Backup each dotfile if it exists and is not a symlink
    for file in "$stow_source_dir"/.* "$stow_source_dir"/*; do
        local base_name=$(basename "$file")
        
        # Skip if it's . or ..
        if [[ "$base_name" == "." || "$base_name" == ".." ]]; then
            continue
        fi
        
        if [ -e "$stow_target_dir/$base_name" ] && [ ! -L "$stow_target_dir/$base_name" ]; then
            mv "$stow_target_dir/$base_name" "$dotfiles_backup_dir/"
            log_message "Backed up $base_name to $dotfiles_backup_dir" "cyan"
        fi
    done
    
    log_message "Dotfiles backup completed." "green"
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