#!/bin/bash

# Path to the directory containing the .mount files
MOUNT_DIR="$HOME/GitHub/dotfiles/.mounts"
SYSTEMD_DIR="/etc/systemd/system"

# Function for color formatting
color_text() {
  case $1 in
    green)
      echo -e "\e[32m$2\e[0m"
      ;;
    orange)
      echo -e "\e[33m$2\e[0m"
      ;;
    red)
      echo -e "\e[31m$2\e[0m"
      ;;
    blue)
      echo -e "\e[34m$2\e[0m"
      ;;
    *)
      echo "$2"
      ;;
  esac
}

# Function to copy and start a specific .mount file
start_mount() {
  if [ -f "$MOUNT_DIR/$1.mount" ]; then
    sudo cp "$MOUNT_DIR/$1.mount" "$SYSTEMD_DIR/"
    if sudo systemctl daemon-reload && sudo systemctl start "$1.mount"; then
      echo -e "$(color_text green "Successfully started $1.mount")"
    else
      echo -e "$(color_text red "Failed to start $1.mount")"
    fi
  else
    echo -e "$(color_text red "Error: $1.mount does not exist in $MOUNT_DIR")"
  fi
}

# Function to stop a specific .mount file
stop_mount() {
  if [ -f "$SYSTEMD_DIR/$1.mount" ]; then
    if sudo systemctl stop "$1.mount"; then
      echo -e "$(color_text green "Successfully stopped $1.mount")"
    else
      echo -e "$(color_text red "Failed to stop $1.mount")"
    fi
  else
    echo -e "$(color_text red "Error: $1.mount does not exist in $SYSTEMD_DIR")"
  fi
}

# Function to copy and enable a specific .mount file
enable_mount() {
  if [ -f "$MOUNT_DIR/$1.mount" ]; then
    sudo cp "$MOUNT_DIR/$1.mount" "$SYSTEMD_DIR/"
    if sudo systemctl daemon-reload && sudo systemctl enable "$1.mount"; then
      echo -e "$(color_text green "Successfully enabled $1.mount")"
    else
      echo -e "$(color_text red "Failed to enable $1.mount")"
    fi
  else
    echo -e "$(color_text red "Error: $1.mount does not exist in $MOUNT_DIR")"
  fi
}

# Function to disable a specific .mount file
disable_mount() {
  if [ -f "$SYSTEMD_DIR/$1.mount" ]; then
    if sudo systemctl disable "$1.mount"; then
      echo -e "$(color_text green "Successfully disabled $1.mount")"
    else
      echo -e "$(color_text red "Failed to disable $1.mount")"
    fi
  else
    echo -e "$(color_text red "Error: $1.mount does not exist in $SYSTEMD_DIR")"
  fi
}

# Function to check the status of .mount files
status_mount() {
  color_text blue "Checking status of .mount files in $MOUNT_DIR and $SYSTEMD_DIR..."
  echo

  # Determine the maximum length of mount file names
  max_length=30
  for mount_file in "$MOUNT_DIR"/*.mount; do
    mount_name=$(basename "$mount_file" .mount)
    if [ ${#mount_name} -gt $max_length ]; then
      max_length=${#mount_name}
    fi
  done

  # Define the format for the output with fixed widths for status, startup, and file
  format="%-${max_length}s status: %-17s | startup: %-16s | file: %-18s\n"

  for mount_file in "$MOUNT_DIR"/*.mount; do
    mount_name=$(basename "$mount_file" .mount)

    # Check if the .mount file exists in the SYSTEMD_DIR
    if [ -f "$SYSTEMD_DIR/$mount_name.mount" ]; then
      # Compare the .mount files in both directories
      if cmp -s "$MOUNT_DIR/$mount_name.mount" "$SYSTEMD_DIR/$mount_name.mount"; then
        file_status="identical"
        file_color="green"
      else
        file_status="differs"
        file_color="red"
      fi

      systemctl_status=$(systemctl is-enabled "$mount_name.mount" 2>/dev/null)
      systemctl_active=$(systemctl is-active "$mount_name.mount" 2>/dev/null)

      if [ "$systemctl_active" = "active" ]; then
        active_status="active"
        active_color="green"
      else
        active_status="inactive"
        active_color="orange"
      fi

      if [ "$systemctl_status" = "enabled" ]; then
        enabled_status="enabled"
        enabled_color="green"
      else
        enabled_status="disabled"
        enabled_color="orange"
      fi

      printf "$format" "$mount_name.mount" "$(color_text $active_color $active_status)" "$(color_text $enabled_color $enabled_status)" "$(color_text $file_color $file_status)"
    else
      printf "$format" "$mount_name.mount" "$(color_text red "inactive")" "$(color_text red "disabled")" "$(color_text red "not in sys")"
    fi
  done
}

# Check if the correct number of arguments is provided
if [ $# -lt 1 ]; then
  echo -e "$(color_text red "Usage: $0 {start|stop|enable|disable|status} <mount_name>")"
  exit 1
fi

# Action from the arguments
ACTION=$1
MOUNT_NAME=$2

# Perform the action based on user input
case $ACTION in
  start) start_mount "$MOUNT_NAME" ;;
  stop) stop_mount "$MOUNT_NAME" ;;
  enable) enable_mount "$MOUNT_NAME" ;;
  disable) disable_mount "$MOUNT_NAME" ;;
  status) status_mount ;;
  *) echo -e "$(color_text red "Invalid action. Use start, stop, enable, disable, or status")" ;;
esac
