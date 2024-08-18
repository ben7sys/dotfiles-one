#!/bin/bash

# Check if DOTFILES_DIR is set, if not, try to autodetect it
if [ -z "$DOTFILES_DIR" ]; then
    echo "Error: DOTFILES_DIR is not set. Attempting to autodetect..."
    if [ -d "$HOME/.dotfiles" ]; then
        export DOTFILES_DIR="$HOME/.dotfiles"
        echo "DOTFILES_DIR autodetected and set to $DOTFILES_DIR"
    else
        echo "Failed to autodetect DOTFILES_DIR. Please set it manually."
        exit 1
    fi
fi
export DOTFILES_SCRIPTS="$DOTFILES_DIR/scripts"

## Ensure the scripts directory exists
if [ ! -d "$DOTFILES_SCRIPTS" ]; then
    echo "Error: Scripts directory not found at $DOTFILES_SCRIPTS" >&2
    exit 1
fi

# Check if menu.sh exists
if [ ! -f "$DOTFILES_SCRIPTS/menu.sh" ]; then
    echo "Error: menu.sh not found in $DOTFILES_SCRIPTS" >&2
    exit 1
fi

## Dynamically set DOTFILES_SCRIPTS based on the location of start.sh
if [ -z "${DOTFILES_SCRIPTS+x}" ]; then
    DOTFILES_SCRIPTS="$DOTFILES_DIR/scripts"
fi
export DOTFILES_SCRIPTS

## Execute menu.sh
exec "$DOTFILES_SCRIPTS/menu.sh"
