#!/bin/bash

# _template.sh: A template for new scripts

## Enable debug mode if needed
# set -x

## Enable strict mode. (error will cause the script to stop)
set -eo pipefail

# Source the config file always. 
source "$(dirname "$0")/config.sh"

# Functions are in the functions.sh file which is sourced in the config.sh file
# --- START SCRIPT ---

# Test wallpaper function
echo "Testing set_wallpaper function..."
set_wallpaper "$DOTFILES_DIR/user/wallpaper_default.jpg"

# Test theme function
echo "Testing set_theme function..."
set_theme "org.kde.breeze.desktop"

# Test icon theme function
echo "Testing set_icon_theme function..."
set_icon_theme "breeze"

# Test plasma reload function
echo "Testing reload_plasma_settings function..."
reload_plasma_settings

echo "All tests completed. Please check the output for any errors."
