#!/bin/bash

## Source files
source "config.sh"
source "functions.sh"
source "install_packages.sh"

## Error handling
exec 2> >(while read -r line; do error_handler "$line"; done)

## --- FUNCTIONS ---


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