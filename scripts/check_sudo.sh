#!/bin/bash

# Check if the script has sudo privileges
check_sudo() {
    if ! sudo -v &> /dev/null; then
        echo "This script requires sudo privileges" 1>&2
        exit 1
    fi
}

# Check if the script is run as root (we generally want to avoid this)
check_not_root() {
    if [ $EUID -eq 0 ]; then
        echo "This script should not be run as root" 1>&2
        exit 1
    fi
}