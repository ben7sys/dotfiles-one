#!/bin/bash

# test-conf.sh
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/.conf"

# Now you can access the variables from the .conf file
echo
echo USER_HOME:         $USER_HOME
echo TARGET_DIRS:       $TARGET_DIRS
echo 
echo AUTOMATED VARIABLES:
echo SOURCE_DIR:        $SOURCE_DIR
echo DOTFILES_DIR:      $DOTFILES_DIR
echo LOGFILE_MOUNTS:    $LOGFILE_MOUNTS
echo