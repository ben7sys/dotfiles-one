#!/bin/bash

## Log the start of the script
log_message "Running Dotfiles: menu.sh $(date '+%Y-%m-%d %H:%M:%S')" "yellow"

## Source files
source "config.sh"
source "functions.sh"
source "install_packages.sh"

## Error handling
exec 2> >(while read -r line; do error_handler "$line"; done)

## --- FUNCTIONS ---


## --- MENU ---

## Main
main() {

    


        

}


# Run the main function if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi