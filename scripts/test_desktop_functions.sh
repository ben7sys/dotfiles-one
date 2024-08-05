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

# Function to set profile picture
set_profile_picture() {
    local picture_path="$1"
    if [ -f "$picture_path" ]; then
        if command_exists plasma-apply-userpicture; then
            plasma-apply-userpicture "$picture_path"
            log_message "Profile picture set to $picture_path" "green"
        else
            log_message "plasma-apply-userpicture not found. Unable to set profile picture." "red"
        fi
    else
        log_message "Profile picture file not found: $picture_path" "red"
    fi
}

# Test profile picture function
echo "Testing set_profile_picture function..."
set_profile_picture "$DOTFILES_DIR/user/ben7sys.png"

# Function to set wallpaper
set_wallpaper() {
    local wallpaper_path="$1"
    if [ -f "$wallpaper_path" ]; then
        if command_exists plasma-apply-wallpaperimage; then
            plasma-apply-wallpaperimage "$wallpaper_path"
            log_message "Wallpaper set to $wallpaper_path" "green"
        else
            log_message "plasma-apply-wallpaperimage not found. Unable to set wallpaper." "red"
        fi
    else
        log_message "Wallpaper file not found: $wallpaper_path" "red"
    fi
}

# Test wallpaper function
echo "Testing set_wallpaper function..."
set_wallpaper "$DOTFILES_DIR/user/wallpaper_default.png"

# Ensure Kvantum is installed using the install_packages function
install_packages "kvantum-qt5"

# Function to set Kvantum theme
set_kvantum_theme() {
    local theme_name="$1"
    local config_file="$HOME/.config/Kvantum/kvantum.kvconfig"

    if [ -f "$config_file" ]; then
        sed -i "s/^theme=.*$/theme=$theme_name/" "$config_file"
        log_message "Kvantum theme set to $theme_name via config file" "green"
    else
        log_message "Kvantum config file not found. Unable to set Kvantum theme." "red"
    fi
}

# Test Kvantum theme function
echo "Testing set_kvantum_theme function..."
set_kvantum_theme "Ocean"

# Function to set system theme
set_theme() {
    local theme_name="$1"
    local theme_dir_local="$HOME/.local/share/plasma/look-and-feel/$theme_name"
    local theme_dir_global="/usr/share/plasma/look-and-feel/$theme_name"

    if command_exists lookandfeeltool; then
        if [ -d "$theme_dir_local" ] || [ -d "$theme_dir_global" ]; then
            lookandfeeltool -a "$theme_name"
            log_message "Theme set to $theme_name" "green"
        else
            log_message "Theme $theme_name not found in local or global directories. Available themes:" "yellow"
            lookandfeeltool -l
        fi
    else
        log_message "lookandfeeltool not found. Unable to set theme." "red"
    fi
}

# Test theme function with Ocean theme
echo "Testing set_theme function with Ocean..."
set_theme "ocean"

# Test theme function with Breeze theme
echo "Testing set_theme function with Breeze..."
set_theme "org.kde.breeze.desktop"

# Function to set color scheme
set_color_scheme() {
    local scheme_name="$1"
    if command_exists plasma-apply-colorscheme; then
        if plasma-apply-colorscheme -l | grep -q "$scheme_name"; then
            plasma-apply-colorscheme "$scheme_name"
            log_message "Color scheme set to $scheme_name" "green"
        else
            log_message "Color scheme $scheme_name not found. Available schemes:" "yellow"
            plasma-apply-colorscheme -l
        fi
    else
        log_message "plasma-apply-colorscheme not found. Unable to set color scheme." "red"
    fi
}

# Test color scheme function
echo "Testing set_color_scheme function (Breeze Dark)..."
set_color_scheme "BreezeDark"

# Function to set icon theme
set_icon_theme() {
    local icon_theme="$1"
    if command_exists plasma-apply-desktoptheme; then
        echo "Executing: plasma-apply-desktoptheme $icon_theme"
        if plasma-apply-desktoptheme "$icon_theme"; then
            log_message "Icon theme set to $icon_theme" "green"
        else
            log_message "Failed to set icon theme $icon_theme. Available themes:" "yellow"
            plasma-apply-desktoptheme --list-themes
        fi
    else
        log_message "plasma-apply-desktoptheme not found. Unable to set icon theme." "red"
    fi
}

# Test icon theme function
echo "Testing set_icon_theme function..."
set_icon_theme "breeze-dark"


echo "All tests completed. Please check the output for any errors."
