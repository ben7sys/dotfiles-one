# Rsync Backup Configuration

## Backup Procedure

A Bash script is automatically executed to start the backup procedure.

- `rsync-backup-sieben.service`: Executes the script
- `rsync-backup-sieben.timer`: Starts the service after a specified time

## Current SystemD File

```
[Unit]
Description=Rsync Backup Sieben Service

[Service]
Type=oneshot
ExecStart=/usr/bin/rsync -h --progress --stats -r -tgo -p -l -D --update --delete-after --delete-excluded --exclude=**/*tmp*/ --exclude=**/*cache*/ --exclude=**/*Cache*/ --exclude=**/*Trash*/ --exclude=**/*trash*/ --exclude=/sieben/.cache/ --exclude=/sieben/.local/share/Steam/ --exclude=/sieben/.local/share/Trash/ --exclude=/sieben/.local/share/baloo/ --exclude=/sieben/Games/ /home/sieben /syno/sieben/eos/
```

## Script Requirements

The script should perform the following functions:

1. Check if the backup directory exists
2. If not, attempt to mount `syno-sieben.mount`
   - Try with stop - wait - start and restart
   - If mounting fails, throw an error and exit
3. Check if the backup directory is writable
   - If not, throw an error and exit
4. Execute the rsync command:

```
ExecStart=/usr/bin/rsync -h --progress --stats -r -tgo -p -l -D --update --delete-after --delete-excluded --exclude=**/*tmp*/ --exclude=**/*cache*/ --exclude=**/*Cache*/ --exclude=**/*Trash*/ --exclude=**/*trash*/ --exclude=/sieben/.cache/ --exclude=/sieben/.local/share/Steam/ --exclude=/sieben/.local/share/Trash/ --exclude=/sieben/.local/share/baloo/ --exclude=/sieben/Games/ /home/sieben /syno/sieben/eos/
```

## syno-sieben.mount File

```
[Unit]
Description=NFS-syno-sieben
Requires=systemd-networkd.service
After=network-online.target
Wants=network-online.target

[Mount]
What=192.168.77.77:/volume1/sieben
Where=/syno/sieben
Type=nfs
Options=_netdev,noauto,x-systemd.automount
TimeoutSec=10

[Install]
WantedBy=multi-user.target
```