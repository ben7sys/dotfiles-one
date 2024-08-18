#!/bin/bash

# functions.sh: Reusable functions for dotfiles management scripts


# -----------------------------------------------------------------------------
# --- ERROR AND LOGGING FUNCTIONS ---
#
# 1. log_message:
#    - Logs detailed messages to a log file without console output by default.
#    - Format: TYP Date Time Message
#    - TYP is determined automatically based on the color:
#      - LOG = green, cyan, blue, magenta, or any color not specified as WARNING or ERROR.
#      - WARNING = yellow.
#      - ERROR = red.
#    - If a color is specified, the message will also be shown on the console in that color.
#
#    Usage:
#    log_message "Your message here" "optional_color"
#    Example: log_message "Backup process started" "none"  # Logs only, no console output
#    Example: log_message "Disk space is running low" "yellow"  # Logs and shows on console in yellow
#
# 2. error_handler:
#    - Handles errors by logging them using the log_message function.
#    - Automatically sets the TYP to ERROR and the color to red.
#    - Logs the error and optionally shows it on the console if a color is provided.
#
#    Usage:
#    error_handler "Your error message here"
#    Example: error_handler "Failed to backup files"  # Logs as ERROR and shows on console in red
#
# 3. color_text (already defined):
#    - Handles the actual color formatting for console output.
#    - Used internally by log_message to colorize output when needed.
#
# -----------------------------------------------------------------------------


# Function to handle errors by logging them using the log_message function
error_handler() {
    local error_message="$1"
    local error_type="${2:-ERROR}"  # Default type is ERROR
    local color="red"  # Default color for errors

    # Log the error message using log_message, with the type determined by the color
    log_message "$error_type" "$error_message" "$color" 
}

# Function to log messages to the log file with detailed information, and optionally to the console if a color is provided
log_message() {
    local message="$1"
    local color="${2:-none}"  # Default is 'none', meaning no console output
    local type="LOG"  # Default type is LOG

    # Determine the type based on the color
    case "$color" in
        yellow)
            type="WARNING"
            ;;
        red)
            type="ERROR"
            ;;
        green|cyan|blue|magenta)
            type="LOG"
            ;;
    esac

    # Format the log entry with type, date, time, and message
    local log_entry="$(date '+%Y-%m-%d %H:%M:%S') $type $message"
    
    # Write the log entry to the log file
    echo "$log_entry" >> "$DOTFILES_LOG"
    
    # If a color is provided, output to the console
    if [[ "$color" != "none" ]]; then
        color_text "$color" "$log_entry"
    fi
}

# -----------------------------------------------------------------------------
# --- REUSABLE FUNCTIONS ---
# -----------------------------------------------------------------------------

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

# Function to ask for user confirmation
confirm_action() {
    local prompt="$1"
    local default="${2:-N}"

    if [[ "$default" =~ ^[Yy]$ ]]; then
        prompt+=" [Y/n] "
    else
        prompt+=" [y/N] "
    fi

    read -p "$prompt" response
    case "$response" in
        [Yy][Ee][Ss]|[Yy]) return 0 ;;
        [Nn][Oo]|[Nn]) return 1 ;;
        *) 
            if [[ "$default" =~ ^[Yy]$ ]]; then
                return 0
            else
                return 1
            fi
            ;;
    esac
}

# Function to parse YAML file
parse_yaml() {
    python3 -c '
import yaml, sys
data = yaml.safe_load(sys.stdin)
for key, value in data.items():
    for package in value:
        print(f"{key}:{package}")
' < "$1"
}

# Function to create systemd service file
create_systemd_service() {
    local service_name="$1"
    local exec_start="$2"
    local service_file="/etc/systemd/system/${service_name}.service"

    cat << EOF > "$service_file"
[Unit]
Description=Create snapshot after boot
After=default.target

[Service]
Type=oneshot
ExecStart=$exec_start

[Install]
WantedBy=default.target
EOF

    systemctl daemon-reload
    systemctl enable "${service_name}.service"
}

# Function to check required environment variables
check_environment_variables() {
    if [ -z "$DOTFILES_DIR" ]; then
        echo "Error: The environment variable DOTFILES_DIR is not set."
        echo "Attempting to autodetect DOTFILES_DIR..."
        autodetect_dotfiles_dir
    fi
}

# Function to autodetect DOTFILES_DIR
autodetect_dotfiles_dir() {
    if [ -d "$HOME/.dotfiles" ]; then
        read -p "DOTFILES_DIR was autodetected as $HOME/.dotfiles. Do you want to use this directory? (y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            export DOTFILES_DIR="$HOME/.dotfiles"
            log_message "DOTFILES_DIR set to $DOTFILES_DIR" "green"
        else
            log_message "DOTFILES_DIR was not set. Please set it manually in start.sh" "red"
            exit 1
        fi
    else
        log_message "Failed to autodetect DOTFILES_DIR. Please set it manually in start.sh" "red"
        exit 1
    fi
}

# Function to check system requirements
check_requirements() {
    log_message "Checking system requirements..." "yellow"
    local required_commands=(git stow jq python)
    local missing_commands=()

    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_commands+=("$cmd")
        fi
    done

    if [ ${#missing_commands[@]} -ne 0 ]; then
        log_message "The following required commands are missing: ${missing_commands[*]}" "red"
        log_message "Installing missing packages..." "yellow"
        sudo pacman -S --needed --noconfirm "${missing_commands[@]}"
    fi

    # Check for PyYAML
    if ! python -c "import yaml" &> /dev/null; then
        log_message "PyYAML is not installed. Installing..." "yellow"
        sudo pacman -S --needed --noconfirm python-yaml
    fi

    log_message "All system requirements are met." "green"
}

# Function to backup existing dotfiles
backup_dotfiles() {
    log_message "Backing up existing dotfiles..." "yellow"

    # Ensure backup directory exists
    mkdir -p "$DOTFILES_BACKUP_DIR"

    # Iterate over all files and directories in stow source directory
    find "$stow_source_dir" -type f | while read -r file; do
        relative_path="${file#$stow_source_dir/}"
        target_file="$stow_target_dir/$relative_path"
        backup_file="$DOTFILES_BACKUP_DIR/$relative_path"
        
        # Backup the file if it exists in target directory and is not a symlink
        if [ -e "$target_file" ] && [ ! -L "$target_file" ]; then
            mkdir -p "$(dirname "$backup_file")"
            mv "$target_file" "$backup_file"
            log_message "Backed up $relative_path to $backup_file" "cyan"
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

# Prevent double sourcing
[ -n "$DOTFILES_FUNCTIONS_SOURCED" ] && return
DOTFILES_FUNCTIONS_SOURCED=1

## Function to make sure the script is run from the correct location
ensure_correct_location() {
    local current_dir=$(pwd)

    if [[ "$current_dir" != "$DOTFILES_DIR" ]]; then
        log_message "Error: Script must run from: $DOTFILES_DIR" "red"
        log_message "Current location: $current_dir" "yellow"
        log_message "You have two options:" "cyan"
        
        echo ""
        # Provide options
        echo "Options:"
        log_message "1. Clone the repository to the correct location:" "cyan"
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo "   git clone $REPO_URL \"$DOTFILES_DIR\""
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo ""
        
        log_message "* Any other key to exit" "cyan"
        echo ""
        
        read -p "Choose an option (1 or any key to exit): " choice
        
        case $choice in
            1)
                if git clone "$REPO_URL" "$DOTFILES_DIR" && cd "$DOTFILES_DIR"; then
                    log_message "Repository cloned successfully to $DOTFILES_DIR" "green"
                else
                    log_message "Failed to clone repository or change directory" "red"
                    exit 1
                fi
                ;;
            *)
                log_message "Exiting. Please run the script from the correct directory." "yellow"
                exit 1
                ;;
        esac
    fi

    log_message "Running from the correct directory: $DOTFILES_DIR" "green"
}


# Export all functions
export -f color_text log_message check_requirements backup_dotfiles \
           check_root check_not_root confirm command_exists \
           ensure_dir_exists symlink_file install_aur_helper check_os setup_user_env \
           ensure_correct_location parse_yaml create_systemd_service \
           check_environment_variables autodetect_dotfiles_dir confirm_action \
           error_handler