#!/bin/bash

USER_HOME="/home/sieben"
DOTFILES_DIR="$USER_HOME/dotfiles"

# Überprüfe, ob nfs-common installiert ist
if ! dpkg -s nfs-common >/dev/null 2>&1; then
    echo "Fehler: nfs-common ist nicht installiert."
    exit 1
fi

# Lese die .conf Datei und führe die Mount-Befehle aus
while read -r line; do
    # Ignoriere Kommentare und leere Zeilen
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue

    # Validiere, dass der Befehl mit 'mount' beginnt
    if [[ "$line" =~ ^mount ]]; then
        # Führe den Befehl aus
        eval $line
        if [ $? -ne 0 ]; then
            echo "Fehler beim Ausführen des Befehls: $line"
            exit 1
        fi
    else
        echo "Nicht erlaubter Befehl: $line"
        exit 1
    fi
done < ~/.mounts/.conf
