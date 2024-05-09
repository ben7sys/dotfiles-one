#!/bin/bash

# Pfadvariablen
USER_HOME=$(eval echo ~$SUDO_USER)
DOTFILES_DIR="$USER_HOME/dotfiles"
TARGET_DIRS=(".config" ".mounts" ".ssh")  # Liste der zu verlinkenden Verzeichnisse

# Funktion, um Verzeichnisse zu verlinken
link_directory() {
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
    sudo cp "$DOTFILES_DIR/.mounts/usermounts.service" /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable usermounts.service
    sudo systemctl start usermounts.service
else
    echo "Service-Datei usermounts.service nicht gefunden in $DOTFILES_DIR/.mounts"
    exit 1
fi

echo "Setup abgeschlossen."