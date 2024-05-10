#!/bin/bash

# Load configuration from .dotfiles.conf
source ~/.linkdotfiles.conf

# Clone dotfiles repository
git clone $GIT_REPO_DOTFILES $DOTFILES_DIR

# Create symlinks only for target dirs
$TARGET_DIRS