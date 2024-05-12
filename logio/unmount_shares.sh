#!/bin/bash

CONFIG_FILE="/etc/mounts.conf"

# Prüfen, ob das Konfigurationsfile existiert
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Konfigurationsdatei nicht gefunden."
    exit 1
fi

# Jede Zeile der Konfigurationsdatei durchgehen
while read -r line; do
    [[ "$line" == \#* ]] || [[ -z "$line" ]] && continue
    
    TARGET=$(echo $line | cut -d ' ' -f3)
    
    # Unmount-Befehl
    umount "$TARGET"
done < "$CONFIG_FILE"
