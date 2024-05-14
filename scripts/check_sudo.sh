#!bin/bash

# Check if the script is run as root and exit if not
if [ $EUID -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi