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

    # Verwende find, um durch alle Dateien und Verzeichnisse in source_dir zu gehen
    # Für jede Datei oder jedes Verzeichnis wird ein relativer Pfad erstellt, 
    # indem der source_dir-Pfad vom vollständigen Pfad entfernt wird. 
    # Dieser relative Pfad wird dann zu target_dir hinzugefügt, 
    # um den Ziel-Pfad zu erstellen. Wenn das Element ein Verzeichnis ist, wird es erstellt. 
    # Wenn es eine Datei ist, wird ein symbolischer Link erstellt.
    find "$source_dir" -mindepth 1 -exec bash -c '
        for filepath do
            local relative_path=${filepath#'"$source_dir"'}
            local target_path='"$target_dir"'$relative_path

            if [ -d "$filepath" ]; then
                # Es handelt sich um ein Verzeichnis
                mkdir -p "$target_path"
                echo "mkdir -p $target_path ausgeführt"
            elif [ -f "$filepath" ]; then
                # Es handelt sich um eine Datei
                ln -sfn "$filepath" "$target_path"
                echo "ln -sfn $filepath $target_path ausgeführt"
            fi
        done
    ' bash {} +
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