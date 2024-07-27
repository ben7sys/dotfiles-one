#!/bin/bash

# Check if the script has sudo privileges
check_sudo() {
    if ! sudo -v &> /dev/null; then
        echo "This script requires sudo privileges" 1>&2
        exit 1
    fi
}