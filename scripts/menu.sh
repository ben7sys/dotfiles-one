#!/bin/bash

# --- CUSTOM CONFIGURATION ---

# Set your DOTFILES_DIR
export DOTFILES_DIR="$HOME/.dotfiles"

# Source necessary files
source "$DOTFILES_DIR/scripts/config.sh"
source "$DOTFILES_DIR/scripts/functions.sh"

## --- CUSTOM SCRIPT CONFIGURATION ---

# Define script directories
SCRIPT_DIRS=(
    "$DOTFILES_DIR/scripts" 
    "$DOTFILES_DIR/gpu-passthrough/scripts"
    "$DOTFILES_DIR/system/scripts"
)

# Define excluded scripts
EXCLUDED_SCRIPTS=("config.sh" "menu.sh" "functions.sh" "_template.sh")

## --- CUSTOM SCRIPT CONFIGURATION END ---

# Log the start of the script
log_message "Running Dotfiles: menu.sh" "yellow"

# --- FUNCTIONS ---

# Function to format directory names into user-friendly titles
format_directory_name() {
    local dir="$1"
    local base_dir=$(basename "$dir")

    # Convert directory names into user-friendly titles
    case "$base_dir" in
        scripts)
            echo "Dotfiles Scripts"
            ;;
        gpu-passthrough)
            echo "GPU-Passthrough Scripts"
            ;;
        system)
            echo "System Scripts"
            ;;
        *)
            # Default to capitalizing the first letter and replacing hyphens/underscores with spaces
            echo "$(echo "$base_dir" | sed -r 's/(^|-|_)(\w)/\U\2/g') Scripts"
            ;;
    esac
}

# Function to list scripts in a specific directory, excluding specified scripts
list_scripts_in_dir() {
    local dir="$1"
    local scripts=()

    while IFS= read -r -d '' script; do
        script_name=$(basename "$script")
        if [[ ! " ${EXCLUDED_SCRIPTS[@]} " =~ " ${script_name} " ]]; then
            scripts+=("$script")
        fi
    done < <(find "$dir" -maxdepth 1 -type f -name "*.sh" -print0)

    echo "${scripts[@]}"
}

# Function to display a menu of available scripts, grouped by directory
display_menu() {
    local all_scripts=()
    local script_number=1

    echo -e "Available scripts:\n"

    for dir in "${SCRIPT_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            # Generate and display the dynamic title
            local title=$(format_directory_name "$dir")
            echo "### $title ###"
            local scripts=($(list_scripts_in_dir "$dir"))
            for script in "${scripts[@]}"; do
                echo "$script_number. $(basename "$script")"
                all_scripts+=("$script")
                ((script_number++))
            done
            echo ""
        else
            log_message "Directory $dir does not exist" "red"
        fi
    done

    if [[ ${#all_scripts[@]} -eq 0 ]]; then
        log_message "No scripts found" "red"
        return
    fi

    read -p "Select a script to run (or type 'q' to quit): " choice

    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice > 0 && choice <= ${#all_scripts[@]} )); then
        run_script "${all_scripts[$((choice - 1))]}"
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
