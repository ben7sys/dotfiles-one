#!/bin/bash

# Pfadvariablen
USER_HOME="/home/sieben"
NFS_SHARE="/mnt/nfs/zmbfs/share/sieben"

# Assoziatives Array für die zu verlinkenden Verzeichnisse
declare -A LINK_DIRS=( ["Bilder"]="Bilder" ["Desktop"]="Schreibtisch" )

# Funktion, um Verzeichnisse zu verlinken
link_directory() {
    local source_dir="$1"
    local target_dir="$2"

    # Wenn das Zielverzeichnis existiert und ein Verzeichnis ist, entferne es
    if [ -d "$target_dir" ]; then
        echo "Verzeichnis $target_dir existiert, wird entfernt..."
        #rm -r "$target_dir"
        echo "rm -r $target_dir ausgeführt"
    fi

    # Erstelle den symbolischen Link
    ln -s "$source_dir" "$target_dir"
    echo "ln -s $source_dir $target_dir ausgeführt"
}

# Verlinken der Verzeichnisse
for dir in "${!LINK_DIRS[@]}"; do
    link_directory "$NFS_SHARE/$dir" "$USER_HOME/${LINK_DIRS[$dir]}"
done

echo "Setup abgeschlossen."