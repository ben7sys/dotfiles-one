#!/bin/bash

# Skript zur Einrichtung von Service-Verzeichnissen und -Dateien

# Anleitung:
# 1. Das Git-Repository dotfiles nach $USER_HOME/dotfiles klonen: git clone https://github.com/ben7sys/dotfiles.git
#    !! Wenn ein anderer Pfad verwendet wird, muss die Variable DOTFILES_DIR entsprechend angepasst werden
# Pfadvariablen
USER_HOME=$(eval echo ~$SUDO_USER)
DOTFILES_DIR="$USER_HOME/dotfiles"
TARGET_DIRS=(".config" ".mounts" ".ssh")  # Liste der zu verlinkenden Verzeichnisse

# Beschreibung:
# Dieses Skript verlinkt die Verzeichnisse .config, .mounts und .ssh aus dem dotfiles-Repository
# in das Home-Verzeichnis des Benutzers. Anschließend wird ein systemd-Service registriert und gestartet
# um die NFS-Mounts aus der .conf-Datei zu konfigurieren und zu starten.
# Jedes Verzeichnis und jede Datei inklusive versteckter Dateien innerhalb der Target-Verzeichnisse wird rekursiv verlinkt
# Beispiel: ./dotfiles/.mounts/.conf wird zu ~/.mounts/.conf verlinkt
# Anschließend werden die NFS-Mounts konfiguriert und gestartet welche in .mounts/.conf definiert sind

# Funktion, um Verzeichnisse zu verlinken
link_directory() {
    # Linke source_dir $1 nach target_dir $2
    local source_dir="$1"
    local target_dir="$2"

    # Überprüfe, ob das Zielverzeichnis existiert, wenn nicht, erstelle es
    if [ ! -d "$target_dir" ]; then
        echo "Verzeichnis $target_dir existiert nicht, wird erstellt..."
        mkdir -p "$target_dir"
        echo "mkdir -p $target_dir ausgeführt"
    fi

    # Kopiere oder verlinke Dateien und Verzeichnisse individuell
    for entry in "$source_dir"/{*,.*}; do
        local entry_name=$(basename "$entry")
        # Ignoriere die speziellen Verzeichnisse . und ..
        if [ "$entry_name" = "." ] || [ "$entry_name" = ".." ]; then
            continue
        fi
        if [ -d "$entry" ]; then
            # Es handelt sich um ein Verzeichnis
            mkdir -p "$target_dir/$entry_name"
            echo "mkdir -p $target_dir/$entry_name ausgeführt"
            link_directory "$entry" "$target_dir/$entry_name"
        elif [ -f "$entry" ]; then
            # Es handelt sich um eine Datei
            ln -sfn "$entry" "$target_dir/$entry_name"
            echo "ln -sfn $entry $target_dir/$entry_name ausgeführt"
        fi
    done
}

# Verlinken der Verzeichnisse
for dir in "${TARGET_DIRS[@]}"; do
    link_directory "$DOTFILES_DIR/$dir" "$USER_HOME/$dir"
done

# Systemd Service registrieren und starten (Beispiel für .mounts)
if [ -f "$DOTFILES_DIR/.mounts/usermounts.service" ]; then
    echo "Registriere und starte systemd service..."
    #sudo cp "$DOTFILES_DIR/.mounts/usermounts.service" /etc/systemd/system/
    sudo ln -s "$USER_HOME/dotfiles/.mounts/usermounts.service" /etc/systemd/system/usermounts.service
    sudo systemctl daemon-reload
    sudo systemctl enable usermounts.service
    sudo systemctl start usermounts.service
else
    echo "Service-Datei usermounts.service nicht gefunden in $DOTFILES_DIR/.mounts"
    exit 1
fi

echo "Setup abgeschlossen."