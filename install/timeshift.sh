#!/bin/bash

# Installiere Timeshift, falls nicht bereits installiert
if ! command -v timeshift &> /dev/null; then
    sudo pacman -S --noconfirm timeshift
fi

# Stelle sicher, dass das Dateisystem BTRFS ist
if ! sudo timeshift --list | grep -q "BTRFS"; then
    echo "BTRFS-Dateisystem ist erforderlich. Bitte überprüfen."
    exit 1
fi

# Erstelle das initiale Snapshot-Konfigurationsverzeichnis, falls nicht vorhanden
if [ ! -d "/etc/timeshift" ]; then
    sudo mkdir -p /etc/timeshift
fi

# Konfiguriere Timeshift für BTRFS-Snapshots
sudo timeshift --snapshot-device /dev/sda1 --create --btrfs

# Erstelle Systemd-Unit für automatischen Snapshot nach dem Boot
SYSTEMD_SERVICE="/etc/systemd/system/timeshift-boot-snapshot.service"
SERVICE_CONTENT=$(cat << 'EOF'
[Unit]
Description=Create Timeshift snapshot after boot
After=default.target

[Service]
ExecStart=/usr/bin/timeshift --create --comments "Auto snapshot after boot" --tags D --scripted
Type=oneshot

[Install]
WantedBy=default.target
EOF
)

# Systemd Service Datei erstellen
echo "$SERVICE_CONTENT" | sudo tee "$SYSTEMD_SERVICE" > /dev/null

# Aktivieren der Systemd-Unit
sudo systemctl daemon-reload
sudo systemctl enable timeshift-boot-snapshot.service

# Installiere grub-btrfs, um die Snapshots im GRUB-Menü verfügbar zu machen
if ! command -v grub-btrfs &> /dev/null; then
    sudo pacman -S --noconfirm grub-btrfs
fi

# Update GRUB-Konfiguration, um die Snapshots anzuzeigen
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "Timeshift-Konfiguration abgeschlossen. Snapshots werden nun nach jedem Boot automatisch erstellt und im GRUB-Menü angezeigt."