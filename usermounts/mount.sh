#!/bin/bash

# Path to the directory containing the .mount files
MOUNT_DIR="$HOME/dotfiles/usermounts"
SYSTEMD_DIR="/etc/systemd/system"

# Function for color formatting
color_text() {
  case $1 in
    green)
      echo -e "\e[32m$2\e[0m"
      ;;
    yellow)
      echo -e "\e[33m$2\e[0m"
      ;;
    red)
      echo -e "\e[31m$2\e[0m"
      ;;
    blue)
      echo -e "\e[34m$2\e[0m"
      ;;
    cyan)
      echo -e "\e[36m$2\e[0m"
      ;;
    magenta)
      echo -e "\e[35m$2\e[0m"
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

# Function to delete a specific .mount file from systemd
delete_mount_file_from_systemd() {
  local mount_name=$1
  local systemd_file="$SYSTEMD_DIR/$mount_name.mount"

  if [ -f "$systemd_file" ]; then
    systemctl_status=$(systemctl is-enabled "$mount_name.mount" 2>/dev/null)
    systemctl_active=$(systemctl is-active "$mount_name.mount" 2>/dev/null)

    if [ "$systemctl_status" = "disabled" ] && [ "$systemctl_active" = "inactive" ]; then
      read -p "Are you sure you want to delete $mount_name.mount from systemd? [y/N]: " confirm
      if [[ "$confirm" =~ ^[Yy]$ ]]; then
        sudo rm "$systemd_file"
        echo -e "$(color_text green "Successfully deleted $mount_name.mount from systemd")"
      else
        echo -e "$(color_text yellow "Deletion of $mount_name.mount canceled")"
      fi
    else
      read -p "$mount_name.mount is not inactive and disabled. Do you want to stop, disable, and delete it? [y/N]: " confirm
      if [[ "$confirm" =~ ^[Yy]$ ]]; then
        sudo systemctl stop "$mount_name.mount"
        sudo systemctl disable "$mount_name.mount"
        sudo rm "$systemd_file"
        echo -e "$(color_text green "Successfully stopped, disabled, and deleted $mount_name.mount from systemd")"
      else
        echo -e "$(color_text yellow "Operation for $mount_name.mount canceled")"
      fi
    fi
  else
    echo -e "$(color_text red "$mount_name.mount does not exist in $SYSTEMD_DIR")"
  fi
}

# Function to check the status of .mount files
status_mount() {
  
clear
  echo -e "Processing $(color_text blue "$MOUNT_DIR") and $(color_text red "$SYSTEMD_DIR") ..."
  echo ""
  
  # Print the table header
  printf "| %-4s | %-33s | %-24s | %-26s | %-20s |\n" \
    "$(color_text blue "o")" \
    "$(color_text blue "Mount-file")" \
    "$(color_text blue "Mount status")" \
    "$(color_text blue "System start")" \
    "$(color_text blue "Compare with systemd")"
  echo -e "----|--------------------------|-----------------|-------------------|----------------------|"


  # Check if the MOUNT_DIR is empty
  if [ -z "$(ls -A "$MOUNT_DIR")" ]; then
    echo -e "$(color_text red "Error: No .mount files found in $MOUNT_DIR")"
    exit 1
  fi

  # Determine the maximum length of mount file names
  max_length=26
  for mount_file in "$MOUNT_DIR"/*.mount; do
    mount_name=$(basename "$mount_file" .mount)
    if [ ${#mount_name} -gt $max_length ]; then
      max_length=${#mount_name}
    fi
  done

  # Define the format for the output with fixed widths for status, startup, and file
  format="%-4s %- ${max_length}s status: %-17s | startup: %-17s | file: %-18s\n"

  i=1
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
        active_color="yellow"
      fi

      if [ "$systemctl_status" = "enabled" ]; then
        enabled_status="enabled"
        enabled_color="green"
      else
        enabled_status="disabled"
        enabled_color="yellow"
      fi

      printf "$format" "$i" "$mount_name.mount" "$(color_text $active_color $active_status)" "$(color_text $enabled_color $enabled_status)" "$(color_text $file_color $file_status)"
    else
      printf "$format" "$i" "$mount_name.mount" "$(color_text red "inactive")" "$(color_text red "disabled")" "$(color_text magenta "not in systemd")"
    fi
    i=$((i + 1))
  done
}

# Function to check if the menu choice is valid
menu_choice_is_valid() {
  if ! [[ "$1" =~ ^[0-9]+$ ]] || [ "$1" -lt 1 ] || [ "$1" -gt "$2" ]; then
    return 1
  else
    return 0
  fi
}

# Function to display the main menu
display_main_menu() {
  clear
  status_mount
  echo ""
  echo "Additional options:"
  echo " r) Refresh"
  echo " x) Exit"
  echo ""
}


# Function to display a menu for a specific .mount file
mount_menu() {
  echo -e "$(color_text blue "Select an action for $1:")"
  echo ""
  echo -e "$(color_text green "1) Mount immediately")"
  echo -e "$(color_text red "2) Unmount immediately")"
  echo -e "$(color_text green "3) Enable Startup Mount")"
  echo -e "$(color_text yellow "4) Disable Startup Mount")"
  echo -e "$(color_text red "5) Delete Mount File from systemd")"
  echo -e "$(color_text green "6) Back to main menu")"
  echo ""
  read -p "Enter your choice: " choice
  echo ""

  if [[ "$choice" =~ ^[1-6]$ ]]; then
    case $choice in
      1) start_mount "$1" ;;
      2) stop_mount "$1" ;;
      3) enable_mount "$1" ;;
      4) disable_mount "$1" ;;
      5) delete_mount_file_from_systemd "$1" ;;
      6) clear && return ;;
    esac
    clear
    main_menu  # Reload the main menu after completing the action
  else
    echo -e "$(color_text red "Invalid choice. Please enter a number between 1 and 6.")"
    echo ""
  fi
}

# Main menu function to handle the main menu logic
main_menu() {
  while true; do
    display_main_menu
    read -p "Enter the number of the mount file or an additional option: " choice

    if [[ "$choice" =~ ^[0-9]+$ ]]; then
      if menu_choice_is_valid "$choice" "$i"; then
        mount_name=$(ls "$MOUNT_DIR"/*.mount | awk -F'/' '{print $NF}' | sed 's/.mount//' | sed -n "${choice}p")
        mount_menu "$mount_name"
        display_main_menu  # Show the main menu again after the submenu action
      else
        echo -e "$(color_text red "Invalid choice. Please enter a valid number.")"
      fi
    elif [[ "$choice" =~ ^[rx]$ ]]; then
      case $choice in
        r) clear && main_menu ;;
        x) exit 0 ;;
      esac
    else
      echo -e "$(color_text red "Invalid choice. Please enter a valid number or option.")"
    fi
  done
}

# Check if the script is called with arguments
if [ $# -eq 0 ]; then
  ACTION="menu"
else
  ACTION=$1
  MOUNT_NAME=$2
fi

# Perform the action based on user input
case $ACTION in
  start) start_mount "$MOUNT_NAME" ;;
  stop) stop_mount "$MOUNT_NAME" ;;
  enable) enable_mount "$MOUNT_NAME" ;;
  disable) disable_mount "$MOUNT_NAME" ;;
  status) status_mount ;;
  menu) main_menu ;;
  *) echo -e "$(color_text red "Invalid action. Use start, stop, enable, disable, status, or menu")" ;;
esac
