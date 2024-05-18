#!/bin/bash

# Dieses Skript setzt das Profilbild für den aktuell angemeldeten Benutzer.
# Pfad und Dateiname Profilbild
BILDVERZEICHNIS="/home/sieben/dotfiles/.dotfiles/img"
BILDNAME="profilbild.png"

# Vollständiger Pfad zum Profilbild
PROFILBILD="$BILDVERZEICHNIS/$BILDNAME"

# Zielverzeichnis für das Profilbild unter Debian KDE
ZIELVERZEICHNIS="/var/lib/AccountsService/icons"

# Bestimme den richtigen Benutzernamen: SUDO_USER wenn gesetzt, sonst `whoami`
if [ ! -z "$SUDO_USER" ]; then
  BENUTZERNAME=$SUDO_USER
else
  BENUTZERNAME=$(whoami)
fi

# Überprüfen, ob das Verzeichnis existiert; wenn nicht, erstelle es
if [ ! -d "$ZIELVERZEICHNIS" ]; then
  sudo mkdir -p "$ZIELVERZEICHNIS"
  sudo chown root:root "$ZIELVERZEICHNIS"
  sudo chmod 755 "$ZIELVERZEICHNIS"
fi

# Profilbild in das Zielverzeichnis kopieren
sudo cp "$PROFILBILD" "$ZIELVERZEICHNIS/$BENUTZERNAME"

# Zugriffsrechte anpassen
sudo chmod 644 "$ZIELVERZEICHNIS/$BENUTZERNAME"
sudo chown root:root "$ZIELVERZEICHNIS/$BENUTZERNAME"

# AccountsService informieren, dass das Bild aktualisiert wurde
if [ -x "$(command -v systemctl)" ]; then
  sudo systemctl restart accounts-daemon
fi

echo "Profilbild wurde erfolgreich gesetzt für Benutzer $BENUTZERNAME."
