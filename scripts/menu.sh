#!/bin/bash

# --- CUSTOM CONFIGURATION ---

# Set your DOTFILES_DIR
export DOTFILES_DIR="$HOME/.dotfiles"

# Source necessary files
source "$DOTFILES_DIR/scripts/config.sh"
source "$DOTFILES_DIR/scripts/functions.sh"

## --- CUSTOM SCRIPT CONFIGURATION ---

# Define script directories
SCRIPT_DIRS=("$DOTFILES_SCRIPTS" "$DOTFILES_DIR/gpu-passthrough/scripts")

# Define excluded scripts
EXCLUDED_SCRIPTS=("config.sh" "menu.sh")

## --- CUSTOM SCRIPT CONFIGURATION END ---

# Log the start of the script
log_message "Running Dotfiles: menu.sh" "yellow"

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
                scripts+=("$base_script")
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
    # Format the output into columns for better readability
    printf "%-4s %-30s %s\n" "No." "Script Name" "Description"
    echo "----------------------------------------------"
    for i in "${!scripts[@]}"; do
        # Customize the description as needed or leave it blank
        local description=""
        printf "%-4d %-30s %s\n" $((i + 1)) "${scripts[$i]}" "$description"
    done
    echo "----------------------------------------------"

    select script in "${scripts[@]}"; do
        if [[ -n "$script" ]]; then
            echo "You selected $script"
            bash "$DOTFILES_DIR/scripts/$script"
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done
}


#ensure_correct_location # Ensure the script is run from the correct directory

# --- MENU ---
# Display the menu to the user
show_menu
