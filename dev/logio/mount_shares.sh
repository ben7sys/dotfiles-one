#!/bin/bash

# Konfigurationsdatei einlesen
CONFIG_FILE="mounts.conf"

# Prüfen, ob das Konfigurationsfile existiert
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Konfigurationsdatei nicht gefunden."
    exit 1
fi

# Jede Zeile der Konfigurationsdatei durchgehen
while read -r line; do
    # Kommentare und leere Zeilen überspringen
    [[ "$line" == \#* ]] || [[ -z "$line" ]] && continue
    
    # Felder auslesen
    TYPE=$(echo $line | cut -d ' ' -f1)
    SOURCE=$(echo $line | cut -d ' ' -f2)
    TARGET=$(echo $line | cut -d ' ' -f3)
    OPTIONS=$(echo $line | cut -d ' ' -f4-)

    # Mount-Befehl basierend auf Typ
    if [ "$TYPE" == "NFS" ]; then
        mount -t nfs "$SOURCE" "$TARGET"
    elif [ "$TYPE" == "SMB" ]; then
        mount -t cifs "$SOURCE" "$TARGET" -o "$OPTIONS"
    else
        echo "Unbekannter Freigabetyp: $TYPE"
    fi
done < "$CONFIG_FILE"
