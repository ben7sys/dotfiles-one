#!/bin/bash

# Utility functions for setup scripts

check_not_root() {
    if [ "$(id -u)" -eq 0 ]; then
        echo "This script should not be run as root" >&2
        exit 1
    fi
}

# Add more utility functions as needed