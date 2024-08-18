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

# Function to list scripts in the given directories, excluding specified scripts
list_scripts() {
    local scripts=()

    for dir in "${SCRIPT_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            # Find all scripts in the directory, excluding the ones in EXCLUDED_SCRIPTS
            while IFS= read -r -d '' script; do
                script_name=$(basename "$script")
                if [[ ! " ${EXCLUDED_SCRIPTS[@]} " =~ " ${script_name} " ]]; then
                    scripts+=("$script")
                fi
            done < <(find "$dir" -type f -name "*.sh" -print0)
        else
            log_message "Directory $dir does not exist" "red"
        fi
    done

    echo "${scripts[@]}"
}

# Function to display a menu of available scripts
display_menu() {
    local scripts=($(list_scripts))
    local script_count=${#scripts[@]}

    if [[ $script_count -eq 0 ]]; then
        log_message "No scripts found" "red"
        return
    fi

    echo "Available scripts:"
    for i in "${!scripts[@]}"; do
        echo "$((i + 1)). $(basename "${scripts[$i]}")"
    done

    echo ""
    read -p "Select a script to run (or type 'q' to quit): " choice

    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice > 0 && choice <= script_count )); then
        run_script "${scripts[$((choice - 1))]}"
    elif [[ "$choice" == "q" ]]; then
        echo "Exiting menu."
    else
        log_message "Invalid selection. Please try again." "yellow"
        display_menu
    fi
}

# Function to run a selected script
run_script() {
    local script="$1"
    log_message "Executing $script" "green"
    bash "$script"
}

# --- MAIN LOGIC ---
#ensure_correct_location
display_menu