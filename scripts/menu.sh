#!/bin/bash

## Dynamically set DOTFILES_DIR based on the location of start.sh
if [ -z "${DOTFILES_DIR+x}" ]; then
    DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi
export DOTFILES_DIR

## Dynamically set DOTFILES_SCRIPTS based on the location of start.sh
if [ -z "${DOTFILES_SCRIPTS+x}" ]; then
    DOTFILES_SCRIPTS="$DOTFILES_DIR/scripts"
fi
export DOTFILES_SCRIPTS

## Dynamically set DOTFILES_CONFIG based on the location of start.sh


## Enable debug mode if needed
# set -x
## Enable strict mode
#set -eo pipefail

## Error handling
exec 2> >(while read -r line; do error_handler "$line"; done)

## --- FUNCTIONS ---

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

## --- Function to handle errors ---
error_handler() {
    local error_message="$1"
    log_message "$error_message" "red" "ERROR"
}

## --- Function to log messages ---
log_message() {
    local message="$1"
    local color="${2:-normal}"
    local level="${3:-INFO}"
    color_text "$color" "[$level] $message"
    echo "$(date): [$level] $message" >> "dotfiles_setup.log"
}

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

## --- MAIN FUNCTION ---

## Main function to orchestrate the setup
main() {
    log_message "Checking requirements for $os..." "yellow"
    
    #ensure_correct_location
    check_not_root
    check_requirements
    
    log_message "Asking the user to backup the existing dotfiles" "yellow"
    # ask the user to backup existing dotfiles before proceeding
    if ! ask_question "Do you want to backup your existing dotfiles?"; then
        log_message "Skipping backup of existing dotfiles..." "yellow"
    else
        backup_dotfiles
        log_message "Your original dotfiles have been backed up to $dotfiles_backup_dir" "cyan"
    fi
        
    # Run Timeshift setup
    log_message "Starting $DOTFILES_DIR/scripts/ultimate_system.sh" "yellow"
    "$DOTFILES_DIR/scripts/setup.sh"
}

## feature request: log_message with date and time to have a better log file
## example: log_message "Dotfiles: start.sh DATE: TIME: " "yellow"

## Log the start of the script
log_message "Running Dotfiles: start.sh $(date '+%Y-%m-%d %H:%M:%S')" "yellow"


# Run the main function if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi