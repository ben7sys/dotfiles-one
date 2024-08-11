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
    
    # Check if the profile picture file exists
    if [ -f "$picture_path" ]; then
        log_message "Setting profile picture..." "green"
        # Copy the profile picture to the default location (redundant in this case, can be omitted)
        cp "$picture_path" ~/.face.icon
        
        # Edit the kdeglobals file to set the user profile picture
        if grep -q "User=" ~/.config/kdeglobals; then
            # If the User entry already exists, replace it with the new picture path
            sed -i "s|^User=.*|User=$picture_path|" ~/.config/kdeglobals
            log_message "Profile picture path updated in kdeglobals." "green"
        else
            # If the User entry does not exist, add the necessary section and entry
            echo "[Icons]" >> ~/.config/kdeglobals
            echo "User=$picture_path" >> ~/.config/kdeglobals
            log_message "Profile picture path added to kdeglobals." "green"
        fi
        log_message "Profile picture successfully set." "green"
    else
        log_message "Profile picture file not found: $picture_path" "red"
    fi
}

# Test the set_profile_picture function
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
install_packages "kvantum"
install_packages "kvantum-qt5"
#install_packages "kvantum-qt6"
#install_packages "kvantum-theme"

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

# Function to set Kvantum theme
set_kvantum_theme() {
    local theme_name="$1"
    local config_file="$HOME/.config/Kvantum/kvantum.kvconfig"

    # Update the Kvantum theme in the configuration file
    if [ -f "$config_file" ]; then
        sed -i "s/^theme=.*$/theme=$theme_name/" "$config_file"
        log_message "Kvantum theme set to $theme_name via config file" "green"
    else
        log_message "Kvantum config file not found. Creating a new one." "yellow"
        echo "[General]" > "$config_file"
        echo "theme=$theme_name" >> "$config_file"
        log_message "Kvantum theme set to $theme_name via new config file" "green"
    fi
}

# Test Kvantum theme function
echo "Testing set_kvantum_theme function..."
#set_kvantum_theme "Ocean"

# Test theme function with Breeze theme
#echo "Testing set_theme function with Breeze..."
#set_theme "org.kde.breeze.desktop"

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
#set_color_scheme "BreezeDark"

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
#set_icon_theme "breeze-dark"


echo "All tests completed. Please check the output for any errors."
