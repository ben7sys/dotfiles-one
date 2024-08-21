#!/bin/bash

# Array of source and target pairs
# ln -s /syno/music ~/Musik/00_syno-musik
# ln -s /syno/downloads ~/Downloads/00_syno-downloads
# ln -s /syno/home/data/Dokumente ~/Dokumente/00_syno-dokumente
# ln -s /syno/home/data/Bilder ~/Bilder/00_syno-bilder

# Enable exit on error and undefined variables
set -euo pipefail

# Array of source and target pairs
declare -A links=(
    ["/syno/music"]="$HOME/Musik"
    ["/syno/downloads"]="$HOME/Downloads"
    ["/syno/home/data/Dokumente"]="$HOME/Dokumente"
    ["/syno/home/data/Bilder"]="$HOME/Bilder"
)

# Function to create a symbolic link
create_link() {
    local source=$1
    local target=$2

    echo "Attempting to create link: $target -> $source"

    # Check if source exists
    if [ ! -e "$source" ]; then
        echo "Error: Source $source does not exist. Skipping."
        return 1
    fi

    # Check if target already exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        echo "Warning: Target $target already exists."
        if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$source" ]; then
            echo "Existing symlink is correct. Skipping."
            return 0
        fi
        read -p "Do you want to replace it? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Skipping link."
            return 0
        fi
        echo "Removing existing target..."
        rm -rf "$target" || { echo "Error: Failed to remove existing target"; return 1; }
    fi

    # Create the symbolic link
    echo "Creating symbolic link..."
    ln -s "$source" "$target" || { echo "Error: Failed to create symbolic link"; return 1; }
    echo "Symbolic link created successfully: $target -> $source"

    # Verify the link
    if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$source" ]; then
        echo "Link verified successfully."
    else
        echo "Error: Link verification failed."
        return 1
    fi
}

# Main script
echo "Starting symbolic link creation process..."

for source in "${!links[@]}"; do
    if create_link "$source" "${links[$source]}"; then
        echo "Link creation successful for $source"
    else
        echo "Link creation failed for $source"
    fi
    echo "------------------------"
done

echo "Script execution completed."
