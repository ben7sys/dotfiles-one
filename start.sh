#!/bin/bash

## Dynamically set DOTFILES_DIR based on the location of start.sh
if [ -z "${DOTFILES_DIR+x}" ]; then
    DETECTED_DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    read -p "Detected DOTFILES_DIR: $DETECTED_DOTFILES_DIR. Do you want to set this as the global DOTFILES_DIR? (y/n) " yn
    case $yn in
        [Yy]* ) DOTFILES_DIR="$DETECTED_DOTFILES_DIR";;
        [Nn]* ) echo "Aborted by user." >&2; exit 1;;
        * ) echo "Invalid response. Aborted." >&2; exit 1;;
    esac
fi
export DOTFILES_DIR

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
