# SystemD Service File Share Mount

# Lerneffekt

Manpages systemd.automount https://manpages.debian.org/testing/manpages-de/systemd.automount.5.de.html

- Eine Unit-Konfigurationsdatei, deren Namen in ».automount« endet

- Automount-Units müssen nach dem Selbsteinhängungsverzeichnis, das sie steuern, benannt sein. 
    Beispiel: Der Selbsteinhängepunkt /home/lennart muss in einer Unit-Datei home-lennart.automount konfiguriert sein.

- Für jede Automount-Unit-Datei muss eine passende Einhänge-Unit-Datei (siehe systemd.mount(5) für Details) existieren, die aktiviert wird, wenn auf den Selbsteinhängungspfad zugegriffen wird.

- Beachten Sie, dass Selbsteinhänge-Units unabhängig von der Einhängung selbst sind, daher sollten Sie hier keine After=- oder Requires=-Einhängeabhängigkeiten setzen.

## Anleitung systemd.automount

- Unit-Files erstellen

```sh
sudo nano home-username.mount
sudo nano home-username.automount
```

```sh
# /home/username/dotfiles/.mounts/home-username.mount
[Unit]
Description=Mount server:/exports/share

[Mount]
What=server:/export/share
Where=/home/username/share
Type=nfs
Options=_netdev,auto

[Install]
WantedBy=multi-user.target

```

```sh
# /home/username/dotfiles/.mounts/home-username.automount
[Unit]
Description=Automount server:/exports/share

[Automount]
Where=/home/username/share
TimeoutIdleSec=30

[Install]
WantedBy=multi-user.target
```

- Files nach systemd linken

```sh
sudo ln -s /home/username/dotfiles/.mounts/home-username.mount /etc/systemd/system/home-username.mount
sudo ln -s /home/username/dotfiles/.mounts/home-username.automount /etc/systemd/system/home-username.automount
sudo systemctl enable home-username.automount
```


# Obsolete

> warning: Die folgende Idee ist obsolete da automount das Problem elegant löst


**anstatt /etc/fstab zu bearbeiten, können ein oder mehrere services, nfs/smb shares mounten**

**Anleitung für User**

```
sudo apt-get install cifs-utils
mount -t cifs -o credentials=/home/username/.smbcredentials //samba.domain.internal/exports /mnt/smb/zmbfs/exports
```

 - service file prüfen
```
sudo nano ~/.smbcredentials
sudo chmod 600 ~/.smbcredentials
sudo -i
ln -s servicefile.service /etc/systemd/system/servicefile.service
systemctl daemon-reload  
systemctl enable nfsmounts.service
systemctl start nfsmounts.service
```

**Service erstellen:**

 - Create a service's unit file with the ".service" suffix in the /etc/systemd/system directory.

systemd:
`/etc/systemd/system/nfsmounts.service`

Filelocation dotfiles clone, home oder `/usr/local/bin` und symlink:

`nano ~/dotfiles/.mounts/nfsmount-zmbfs-share.service`
`nano /usr/local/bin/nfsmounts.service`

`ln -s ~/dotfiles/.mounts/mount-nfs.service.example /etc/systemd/system/nfsmounts.service`
`ln -s /usr/local/bin/nfsmounts.service /etc/systemd/system/nfsmounts.service`

> :warning: Die entsprechenden mount folder müssen angelegt sein damit der dienst funktioniert

`mkdir -d /mnt/nfs`
`mkdir -d /mnt/nfs/servername`


**Example Content of nfsmounts.service**
```
[Unit]  
Description=Custom Service to mount NFS
After=network-online.target
Wants=network-online.target
  
[Service]  
Type=oneshot  
ExecStart=/bin/mount -o hard,nolock 192.168.0.XXX:/share/folder /mnt/nfs/servername/folder
ExecStop=/bin/umount /mnt/nfs/servername/folder

[Install]  
WantedBy=multi-user.target  
```

Service registrieren und starten
```
systemctl daemon-reload  
systemctl enable nfsmounts.service
systemctl start nfsmounts.service
```
