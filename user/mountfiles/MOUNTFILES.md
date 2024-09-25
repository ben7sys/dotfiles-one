# Übersicht der Synology NAS Mounts

## Allgemeine Informationen

Alle Mounts verwenden die folgenden gemeinsamen Optionen:
- `uid=1000,gid=1000`: Setzt den Besitzer und die Gruppe für die gemounteten Dateien
- `credentials=/home/sieben/.smbcred`: Verwendet die in dieser Datei gespeicherten Anmeldeinformationen
- `file_mode=0755,dir_mode=0755`: Setzt die Berechtigungen für Dateien und Verzeichnisse

## Mount-Übersicht

1. Video Mount
   - Quelle: //192.168.77.77/video
   - Ziel: /syno/video
   - Mountbefehl:
     ```
     sudo mount -t cifs //192.168.77.77/video /syno/video -o uid=1000,gid=1000,credentials=/home/sieben/.smbcred,file_mode=0755,dir_mode=0755
     ```

2. Software Mount
   - Quelle: //192.168.77.77/software
   - Ziel: /syno/software
   - Mountbefehl:
     ```
     sudo mount -t cifs //192.168.77.77/software /syno/software -o uid=1000,gid=1000,credentials=/home/sieben/.smbcred,file_mode=0755,dir_mode=0755
     ```

3. Share Mount
   - Quelle: //192.168.77.77/share
   - Ziel: /syno/share
   - Mountbefehl:
     ```
     sudo mount -t cifs //192.168.77.77/share /syno/share -o uid=1000,gid=1000,credentials=/home/sieben/.smbcred,file_mode=0755,dir_mode=0755
     ```

4. Music Mount
   - Quelle: //192.168.77.77/music
   - Ziel: /syno/music
   - Mountbefehl:
     ```
     sudo mount -t cifs //192.168.77.77/music /syno/music -o uid=1000,gid=1000,credentials=/home/sieben/.smbcred,file_mode=0755,dir_mode=0755
     ```

5. Home Mount
   - Quelle: //192.168.77.77/home
   - Ziel: /syno/home
   - Mountbefehl:
     ```
     sudo mount -t cifs //192.168.77.77/home /syno/home -o uid=1000,gid=1000,credentials=/home/sieben/.smbcred,file_mode=0755,dir_mode=0755
     ```

6. Games Mount
   - Quelle: //192.168.77.77/games
   - Ziel: /syno/games
   - Mountbefehl:
     ```
     sudo mount -t cifs //192.168.77.77/games /syno/games -o uid=1000,gid=1000,credentials=/home/sieben/.smbcred,file_mode=0755,dir_mode=0755
     ```

7. Downloads Mount
   - Quelle: //192.168.77.77/downloads
   - Ziel: /syno/downloads
   - Mountbefehl:
     ```
     sudo mount -t cifs //192.168.77.77/downloads /syno/downloads -o uid=1000,gid=1000,credentials=/home/sieben/.smbcred,file_mode=0755,dir_mode=0755
     ```

8. Cloudsync Mount
   - Quelle: //192.168.77.77/cloudsync
   - Ziel: /syno/cloudsync
   - Mountbefehl:
     ```
     sudo mount -t cifs //192.168.77.77/cloudsync /syno/cloudsync -o uid=1000,gid=1000,credentials=/home/sieben/.smbcred,file_mode=0755,dir_mode=0755
     ```

9. Backup Mount
   - Quelle: //192.168.77.77/backup
   - Ziel: /syno/backup
   - Mountbefehl:
     ```
     sudo mount -t cifs //192.168.77.77/backup /syno/backup -o uid=1000,gid=1000,credentials=/home/sieben/.smbcred,file_mode=0755,dir_mode=0755
     ```

10. Archiv Mount
    - Quelle: //192.168.77.77/archiv
    - Ziel: /syno/archiv
    - Mountbefehl:
      ```
      sudo mount -t cifs //192.168.77.77/archiv /syno/archiv -o uid=1000,gid=1000,credentials=/home/sieben/.smbcred,file_mode=0755,dir_mode=0755
      ```

## Automatisches Mounten

Diese Mounts können automatisch beim Systemstart über systemd Mount-Units eingebunden werden. Die entsprechenden `.mount`-Dateien befinden sich im Verzeichnis `/etc/systemd/system/`.

Um einen Mount zu aktivieren und beim Systemstart automatisch einzubinden, verwenden Sie:

```bash
sudo systemctl enable syno-<name>.mount
sudo systemctl start syno-<name>.mount
```

Ersetzen Sie `<name>` durch den entsprechenden Mount-Namen (z.B. video, software, share, etc.).

## Hinweise

- Stellen Sie sicher, dass die Zielverzeichnisse (`/syno/<name>`) existieren, bevor Sie die Mounts aktivieren.
- Überprüfen


# Liste der Pfade

//192.168.77.77/video - /syno/video
//192.168.77.77/software - /syno/software
//192.168.77.77/share - /syno/share
//192.168.77.77/music - /syno/music
//192.168.77.77/home - /syno/home
//192.168.77.77/games - /syno/games
//192.168.77.77/downloads - /syno/downloads
//192.168.77.77/cloudsync - /syno/cloudsync
//192.168.77.77/backup - /syno/backup
//192.168.77.77/archiv - /syno/archiv