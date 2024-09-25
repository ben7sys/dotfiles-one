#!/bin/bash

# List of syno mount units to start
SYNO_MOUNTS=(
    "syno-sieben.mount"
    "syno-backup.mount"
)

# List of services to start
SERVICES=(
    "docker"
    # Add other services here, for example:
    # "nginx"
    # "postgresql"
)

# Function to check if NetworkManager is running
check_network() {
    echo "Checking network status..."
    for i in {1..30}; do
        if systemctl is-active --quiet NetworkManager; then
            echo "NetworkManager is running."
            return 0
        fi
        echo "Waiting for NetworkManager... (attempt $i/30)"
        sleep 2
    done
    echo "NetworkManager did not start in time."
    return 1
}

# Function to start syno mounts
start_syno_mounts() {
    for mount in "${SYNO_MOUNTS[@]}"; do
        if systemctl is-active --quiet "$mount"; then
            echo "$mount is already running."
        else
            echo "Starting $mount"
            if sudo systemctl start "$mount"; then
                echo "$mount started successfully."
            else
                echo "Failed to start $mount. Error code: $?"
                return 1
            fi
            sleep 1
        fi
    done
    return 0
}

# Function to start services
start_services() {
    for service in "${SERVICES[@]}"; do
        if systemctl is-active --quiet "$service"; then
            echo "$service is already running."
        else
            echo "Starting $service"
            if sudo systemctl start "$service"; then
                echo "$service started successfully."
            else
                echo "Failed to start $service. Error code: $?"
                return 1
            fi
            sleep 1
        fi
    done
    return 0
}

# Main execution
if check_network; then
    if start_syno_mounts && start_services; then
        # Add any other systemd units you want to start here
        echo "Startup script completed successfully."
    else
        echo "Startup script failed due to mount or service startup issues."
        exit 1
    fi
else
    echo "Startup script failed due to network issues."
    exit 1
fi
