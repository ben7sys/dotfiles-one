# SystemD Service File Share Mount

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
