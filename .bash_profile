#!/bin/bash
# ~/.bash_profile: executed by bash for login shells.

# Source .profile for environment settings
if [ -f "$HOME/.profile" ]; then
    source "$HOME/.profile"
fi

# Source .bashrc for interactive shell settings if this is an interactive shell
if [[ $- == *i* ]] && [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi

# Bash-specific login configurations can be added here

# Example: Set up ssh-agent if not already running
# if [ -z "$SSH_AUTH_SOCK" ]; then
#     eval "$(ssh-agent -s)"
#     ssh-add
# fi

# Print a welcome message on login
echo "Welcome, $USER. It's $(date +"%A, %d %B %Y, %T")"