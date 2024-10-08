#!/bin/bash

# Set your DOTFILES_DIR
export DOTFILES_DIR="$HOME/.dotfiles"

# Source necessary files
source "$DOTFILES_DIR/scripts/config.sh"
source "$DOTFILES_DIR/scripts/functions.sh"

## Set the scripts directory ** DO NOT CHANGE **
export DOTFILES_SCRIPTS="$DOTFILES_DIR/scripts"

## Log the start of the script
log_message "#######################################################"
log_message "Running Dotfiles: start.sh $(date '+%Y-%m-%d %H:%M:%S')" "cyan"
log_message "#######################################################"



check_environment_variables

## Ensure the scripts directory exists
if [ ! -d "$DOTFILES_SCRIPTS" ]; then
    log_message "Error: Scripts directory not found at $DOTFILES_SCRIPTS ...Exit..." "red"
    exit 1
fi

# Check if menu.sh exists
if [ ! -f "$DOTFILES_SCRIPTS/menu.sh" ]; then
    log_message "Error: menu.sh not found in $DOTFILES_SCRIPTS ...Exit..." "red"
    exit 1
fi

## Execute menu.sh
exec "$DOTFILES_SCRIPTS/menu.sh"
