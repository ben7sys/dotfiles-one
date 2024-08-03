#!/bin/bash

# timeshift_setup.sh: Configure Timeshift and Snapper for BTRFS snapshots

# Function to display usage information
show_usage() {
    echo "Usage: $0 [DOTFILES_DIR]"
    echo "  or:  DOTFILES_DIR=/path/to/dotfiles $0"
    echo ""
    echo "This script configures Timeshift and Snapper for BTRFS snapshots."
    echo "It can be run either through setup.sh or manually with the dotfiles directory specified."
    echo ""
    echo "If run manually, you must either:"
    echo "  1. Provide the path to your dotfiles directory as an argument, or"
    echo "  2. Set the DOTFILES_DIR environment variable before running the script."
    echo ""
    echo "Example:"
    echo "  $0 \$HOME/.dotfiles"
    echo "  or"
    echo "  DOTFILES_DIR=\$HOME/.dotfiles $0"
    echo ""
    echo "Note: This script requires root privileges to run certain actions."
}

# Check for help argument
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_usage
    exit 0
fi

# Determine dotfiles directory
if [ -n "$DOTFILES_DIR" ]; then
    dotfiles_dir="$DOTFILES_DIR"
    echo "Using DOTFILES_DIR from environment variable: $dotfiles_dir"
elif [ -n "$1" ]; then
    dotfiles_dir="$1"
    echo "Using DOTFILES_DIR from command line argument: $dotfiles_dir"
else
    echo "Error: DOTFILES_DIR not set and no argument provided." >&2
    echo ""
    show_usage
    exit 1
fi

# Verify that dotfiles_dir exists and is a directory
if [ ! -d "$dotfiles_dir" ]; then
    echo "Error: $dotfiles_dir is not a valid directory." >&2
    exit 1
fi

# Source the config file and functions
if [ -f "$dotfiles_dir/config.sh" ]; then
    source "$dotfiles_dir/config.sh"
else
    echo "Error: config.sh not found in $dotfiles_dir" >&2
    exit 1
fi

if [ -f "$dotfiles_dir/functions.sh" ]; then
    source "$dotfiles_dir/functions.sh"
else
    echo "Error: functions.sh not found in $dotfiles_dir" >&2
    exit 1
fi

# Function to check Timeshift-specific requirements
check_timeshift_requirements() {
    log_message "Checking Timeshift-specific requirements..." "yellow"
    local requirements_met=true

    # Check for BTRFS filesystem
    if ! mount | grep -q "type btrfs"; then
        log_message "BTRFS filesystem not detected. Timeshift requires BTRFS for snapshots." "red"
        requirements_met=false
    fi

    # Check available disk space (example: 5GB free space required)
    local free_space=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$free_space" -lt 5 ]; then
        log_message "Less than 5GB free space available. This might not be enough for snapshots." "yellow"
        requirements_met=false
    fi

    # Check if required commands are available
    local required_commands=(timeshift snapper grub-mkconfig)
    local missing_commands=()

    for cmd in "${required_commands[@]}"; do
        if ! command_exists "$cmd"; then
            missing_commands+=("$cmd")
            requirements_met=false
        fi
    done

    if [ ${#missing_commands[@]} -ne 0 ]; then
        log_message "The following required commands are missing: ${missing_commands[*]}" "red"
        log_message "Please install the missing packages before proceeding." "yellow"
    fi

    if [ "$requirements_met" = false ]; then
        log_message "Timeshift-specific requirements not fully met. Please address the issues above before proceeding." "red"
        if ! confirm_action "Do you want to continue anyway?" "N"; then
            log_message "Exiting due to unmet Timeshift requirements." "yellow"
            return 1
        fi
    else
        log_message "All Timeshift-specific requirements are met." "green"
    fi

    return 0
}

# Check general requirements
check_requirements || { log_message "Failed to meet general system requirements. Exiting." "red"; exit 1; }

# Check Timeshift-specific requirements
check_timeshift_requirements || { log_message "Failed to meet Timeshift-specific requirements. Exiting." "red"; exit 1; }

# Backup GRUB configuration before modifying
backup_grub_config() {
    if [ -f /etc/default/grub ]; then
        sudo cp /etc/default/grub /etc/default/grub.bak
        log_message "Backup of GRUB configuration created at /etc/default/grub.bak" "green"
    else
        log_message "No GRUB configuration file found to backup." "yellow"
    fi
}

# Inform user about potential changes
log_message "This script will perform the following actions:" "yellow"
echo "1. Install Timeshift, Snapper, and grub-btrfs if not already installed."
echo "2. Configure Timeshift for system snapshots (excluding /home)."
echo "3. Configure Snapper for /home snapshots."
echo "4. Create systemd units for automatic snapshots."
echo "5. Modify GRUB configuration to show snapshots in the boot menu."
echo ""
log_message "These changes can potentially affect your system's boot process and disk usage." "red"
log_message "Please ensure you have a backup before proceeding." "red"
echo ""

if ! confirm_action "Do you want to proceed with these changes?"; then
    log_message "Operation cancelled by user." "yellow"
    exit 0
fi

# Install necessary packages if not already installed
install_if_not_exists() {
    local package="$1"
    if ! command_exists "$package"; then
        if confirm_action "Package $package is not installed. Do you want to install it?"; then
            log_message "Installing $package..." "yellow"
            sudo pacman -S --noconfirm "$package" || { log_message "Failed to install $package" "red"; exit 1; }
        else
            log_message "Skipping installation of $package. This may affect the script's functionality." "yellow"
        fi
    else
        log_message "$package is already installed" "green"
    fi
}

packages_to_install="timeshift snapper grub-btrfs"
for package in $packages_to_install; do
    install_if_not_exists "$package"
done

# Configure Timeshift for system (excluding /home)
if ! timeshift --list | grep -q "btrfs"; then
    if confirm_action "Configure Timeshift for system snapshots?"; then
        log_message "Configuring Timeshift for system snapshots..." "yellow"
        sudo timeshift --btrfs --snapshot-device /dev/sda2 --exclude "/home/**" --create || { log_message "Failed to configure Timeshift" "red"; exit 1; }
    else
        log_message "Skipping Timeshift configuration." "yellow"
    fi
else
    log_message "Timeshift is already configured for BTRFS" "green"
fi

# Configure Snapper for /home
if ! snapper list-configs | grep -q "home"; then
    if confirm_action "Configure Snapper for /home snapshots?"; then
        log_message "Configuring Snapper for /home snapshots..." "yellow"
        sudo snapper -c home create-config /home || { log_message "Failed to configure Snapper for /home" "red"; exit 1; }
    else
        log_message "Skipping Snapper configuration for /home." "yellow"
    fi
else
    log_message "Snapper is already configured for /home" "green"
fi

# Create Systemd units for automatic snapshots
if confirm_action "Create systemd units for automatic snapshots?"; then
    sudo create_systemd_service "timeshift-boot-snapshot" "/usr/bin/timeshift --create --comments 'Auto snapshot after boot' --tags B"
    sudo create_systemd_service "snapper-boot-snapshot" "/usr/bin/snapper -c home create -c timeline -d 'Auto snapshot after boot'"
else
    log_message "Skipping creation of systemd units for automatic snapshots." "yellow"
fi

# Configure GRUB to show snapshots
if ! grep -q "GRUB_DISABLE_SUBMENU=n" /etc/default/grub; then
    if confirm_action "Modify GRUB configuration to show snapshots in boot menu?"; then
        backup_grub_config
        log_message "Configuring GRUB to show snapshots..." "yellow"
        sudo sed -i 's/GRUB_DISABLE_SUBMENU=y/GRUB_DISABLE_SUBMENU=n/' /etc/default/grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg || { log_message "Failed to update GRUB configuration" "red"; exit 1; }
    else
        log_message "Skipping GRUB configuration modification." "yellow"
    fi
else
    log_message "GRUB is already configured to show submenus" "green"
fi

log_message "Snapshot configuration completed." "green"
log_message "System snapshots (excluding /home) will be managed by Timeshift." "cyan"
log_message "/home snapshots will be managed by Snapper." "cyan"
log_message "Snapshots will be available in the GRUB menu at boot." "cyan"
log_message "To manage snapshots manually:" "yellow"
log_message "  - For system: use 'timeshift' command" "yellow"
log_message "  - For /home: use 'snapper -c home' commands" "yellow"
