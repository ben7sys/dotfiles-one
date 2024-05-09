#!/bin/bash

# Dieses Script mountet NFS-Verzeichnisse, die in der .conf Datei definiert sind
# Die .conf Datei sollte im Verzeichnis $USER_HOME/.mounts liegen
# Das Script überprüft, ob nfs-common installiert ist
# und ob die Verzeichnisse bereits gemountet sind
# Wenn nicht, wird der Befehl aus der .conf Datei ausgeführt

# Pfadvariablen
USER_HOME="/home/sieben"
DOTFILES_DIR="$USER_HOME/dotfiles"
LOGFILE="$USER_HOME/.mounts/mounts.log"

# Überprüfe, ob nfs-common installiert ist
if ! dpkg -s nfs-common >/dev/null 2>&1; then
    echo "Fehler: nfs-common ist nicht installiert." | tee -a $LOGFILE
    exit 1
fi

# Funktion zu prüfen, ob ein Verzeichnis bereits gemountet ist
check_mounted() {
    local dir="$1"

    # Überprüfe, ob das Verzeichnis ein Mountpunkt ist
    if mountpoint -q "$dir"; then
        echo "Das Verzeichnis $dir ist bereits gemountet." | tee -a $LOGFILE
        return 0
    else
        echo "Das Verzeichnis $dir ist nicht gemountet." | tee -a $LOGFILE
        return 1
    fi
}


# Funktion die die .conf Datei liest und die Mount-Befehle ausführt
# Die Funktion ruft check_mounted auf, um zu überprüfen, ob das Verzeichnis bereits gemountet ist
function mount_nfs() {
    # Lese die .conf Datei und führe die Mount-Befehle aus
    while read -r line; do
        # Ignoriere Kommentare und leere Zeilen
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue

        # Validiere, dass der Befehl mit 'mount' beginnt
        if [[ "$line" =~ ^mount ]]; then
            # Extrahiere das Verzeichnis aus dem mount Befehl
            dir=$(echo $line | awk '{print $3}')

            # Überprüfe, ob das Verzeichnis bereits gemountet ist
            if check_mounted $dir; then
                echo "Überspringe das Mounten von $dir, da es bereits gemountet ist." | tee -a $LOGFILE
                continue
            fi

            # Führe den Befehl aus
            echo "Ausführung des Befehls: $line" | tee -a $LOGFILE
            eval $line 2>>$LOGFILE
            if [ $? -ne 0 ]; then
                echo "Fehler beim Ausführen des Befehls: $line" | tee -a $LOGFILE
                exit 1
            fi
        else
            echo "Nicht erlaubter Befehl: $line" | tee -a $LOGFILE
            exit 1
        fi
    done < "$USER_HOME/.mounts/.conf"
}

# Aufruf der mount_nfs Funktion
mount_nfs

