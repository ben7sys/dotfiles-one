#!/bin/bash

# Log the start of the script
log_message "Running Dotfiles: menu.sh $(date '+%Y-%m-%d %H:%M:%S')" "yellow"

# Source necessary files
source "$DOTFILES_SCRIPTS/config.sh"
source "$DOTFILES_SCRIPTS/functions.sh"
source "$DOTFILES_SCRIPTS/install_packages.sh"

# Error handling
exec 2> >(while read -r line; do error_handler "$line"; done)

# --- CONFIGURATION ---

# Define script directories
SCRIPT_DIRS=("$DOTFILES_SCRIPTS" "$DOTFILES_DIR/gpu-passthrough/scripts")

# Define excluded scripts
EXCLUDED_SCRIPTS=("config.sh" "menu.sh")

# --- FUNCTIONS ---

# Function to list available scripts in the specified directories
list_scripts() {
    local scripts=()
    for dir in "${SCRIPT_DIRS[@]}"; do
        # Find all scripts in the directory
        for script in "$dir"/*.sh; do
            # Check if the script is in the excluded list
            local base_script=$(basename "$script")
            if [[ ! " ${EXCLUDED_SCRIPTS[@]} " =~ " ${base_script} " ]]; then
                scripts+=("$script")
            fi
        done
    done
    echo "${scripts[@]}"
}

# Function to display the menu and get user selection
show_menu() {
    local scripts=($(list_scripts))
    local PS3="Please select a script to execute: "

    echo "Available scripts:"
    select script in "${scripts[@]}"; do
        if [[ -n "$script" ]]; then
            echo "You selected $script"
            bash "$script"
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done
}

# --- MENU ---

ensure_correct_location # Ensure the script is run from the correct directory

# Display the menu to the user
show_menu
