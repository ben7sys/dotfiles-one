#!/bin/bash

VM_NAME="win10"  # Ersetzen Sie dies mit dem Namen Ihrer VM
QEMU_MONITOR_SOCKET="/tmp/qemu-monitor-socket"

# Funktion zum Senden von Befehlen an den QEMU-Monitor
send_qemu_command() {
    echo $1 | sudo socat - UNIX-CONNECT:$QEMU_MONITOR_SOCKET
}

# Funktion zum Aktivieren des QEMU-Displays
enable_display() {
    send_qemu_command "display enabled"
    echo "QEMU-Display wurde aktiviert."
}

# Funktion zum Deaktivieren des QEMU-Displays
disable_display() {
    send_qemu_command "display disabled"
    echo "QEMU-Display wurde deaktiviert."
}

# Funktion zum Anzeigen des aktuellen Display-Status
show_status() {
    status=$(send_qemu_command "info display" | grep "enabled")
    if [[ $status == *"true"* ]]; then
        echo "QEMU-Display ist derzeit aktiviert."
    else
        echo "QEMU-Display ist derzeit deaktiviert."
    fi
}

# Hauptmenü
while true; do
    echo "QEMU Display Manager"
    echo "1. QEMU-Display aktivieren"
    echo "2. QEMU-Display deaktivieren"
    echo "3. Status anzeigen"
    echo "4. Beenden"
    read -p "Wählen Sie eine Option (1-4): " choice

    case $choice in
        1) enable_display ;;
        2) disable_display ;;
        3) show_status ;;
        4) echo "Programm wird beendet."; exit 0 ;;
        *) echo "Ungültige Auswahl. Bitte versuchen Sie es erneut." ;;
    esac

    echo
done
