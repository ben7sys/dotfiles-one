#!/bin/bash

# Start mount-syno.sh
/home/sieben/GitHub/dotfiles-one/scripts/mount-syno.sh

# Check if mount-syno.sh was successful
if [ $? -eq 0 ]; then
    echo "mount-syno.sh was executed successfully."
    
    # Wait for 2 seconds
    sleep 2
    
    # Check if Docker is running
    if ! systemctl is-active --quiet docker; then
        echo "Docker is not running. Starting Docker..."
        systemctl start docker
    else
        echo "Docker is already running."
    fi
    
    # Check if add-static-route.service is running
    if systemctl is-active --quiet add-static-route.service; then
        echo "add-static-route.service is running. Restarting..."
        systemctl restart add-static-route.service
    else
        echo "add-static-route.service is not running. Starting..."
        systemctl start add-static-route.service
    fi
else
    echo "Error: mount-syno.sh could not be executed successfully."
    exit 1
fi
