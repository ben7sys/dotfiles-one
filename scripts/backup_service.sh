#!/bin/bash
set -x  # Aktiviert Debug-Modus

# Define variables
SOURCE_DIR="/home/sieben"
BACKUP_DIR="/syno/sieben"
BACKUP_TARGET="$BACKUP_DIR/eos/"
MOUNT_UNIT="syno-sieben.mount"
DRY_RUN=true
LOG_FILE="/home/sieben/backup_service.log"  # Updated log file path

# Function to log messages
log_message() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$message"
    echo "$message" >> "$LOG_FILE"
}

# New function to display progress
display_progress() {
    local message=$1
    local current=$2
    local total=$3
    local percentage=$((current * 100 / total))
    printf "\r%-30s [%-50s] %d%%" "$message" $(printf "#%.0s" $(seq 1 $((percentage / 2)))) $percentage
}

# Function to check if the backup directory is mounted and writable
check_backup_directory() {
    # Check if the backup directory is mounted
    if ! mountpoint -q "$BACKUP_DIR"; then
        log_message "Backup directory is not mounted. Attempting to mount..."
        
        # Attempt to mount syno-sieben.mount
        systemctl stop "$MOUNT_UNIT"
        sleep 5
        systemctl start "$MOUNT_UNIT"
        sleep 5
        
        if ! mountpoint -q "$BACKUP_DIR"; then
            log_message "ERROR: Failed to mount backup directory. Exiting."
            exit 1
        fi
    fi

    # Check if the backup directory is writable
    if [ ! -w "$BACKUP_DIR" ]; then
        log_message "ERROR: Backup directory is not writable. Exiting."
        exit 1
    fi

    # Create backup target directory if it doesn't exist
    if [ ! -d "$BACKUP_TARGET" ]; then
        log_message "Creating backup target directory..."
        mkdir -p "$BACKUP_TARGET"
        if [ $? -ne 0 ]; then
            log_message "ERROR: Failed to create backup target directory. Exiting."
            exit 1
        fi
    fi

    log_message "Backup directory is mounted and writable."
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --active)
            DRY_RUN=false
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Main script execution
log_message "Starting rsync backup procedure"

# Check backup directory
check_backup_directory

# Rsync-Befehl als Array definieren
rsync_args=(
    -ah
    --info=progress2
    --stats
    -r
    -tgo
    -p
    -l
    -D
    --update
    --delete-after
    --delete-excluded
    --exclude='**/*tmp*/'
    --exclude='**/*cache*/'
    --exclude='**/*Cache*/'
    --exclude='**/*Trash*/'
    --exclude='**/*trash*/'
    --exclude='/sieben/.cache/'
    --exclude='/sieben/.local/share/Steam/'
    --exclude='/sieben/.local/share/Trash/'
    --exclude='/sieben/.local/share/baloo/'
    --exclude='/sieben/Games/'
    "$SOURCE_DIR"
    "$BACKUP_TARGET"
)

if [ "$DRY_RUN" = true ]; then
    rsync_args+=(--dry-run)
    log_message "Führe Dry Run aus"
else
    log_message "Führe aktives Backup aus"
fi

# Rsync-Befehl ausführen und Ausgabe erfassen
log_message "Führe rsync-Befehl aus"
rsync_output=$(rsync "${rsync_args[@]}" 2>&1)
rsync_exit_code=$?

# Rsync-Ergebnis überprüfen und loggen
if [ $rsync_exit_code -eq 0 ]; then
    if [ "$DRY_RUN" = true ]; then
        log_message "Dry Run erfolgreich abgeschlossen"
    else
        log_message "Rsync-Backup erfolgreich abgeschlossen"
    fi
    log_message "Rsync-Ausgabe: $rsync_output"
else
    log_message "FEHLER: Rsync fehlgeschlagen mit Exit-Code $rsync_exit_code"
    log_message "Rsync-Ausgabe: $rsync_output"
    exit 1
fi

log_message "Backup-Vorgang beendet"
exit 0