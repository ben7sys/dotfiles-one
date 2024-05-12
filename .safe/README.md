# SystemD Service File Share Mount

**anstatt /etc/fstab zu bearbeiten, können ein oder mehrere services, nfs/smb shares mounten**

**Anleitung für User**


sudo apt-get install cifs-utils
mount -t cifs -o credentials=/home/username/.smbcredentials //samba.domain.internal/exports /mnt/smb/zmbfs/exports

service file prüfen
sudo nano ~/.smbcredentials
sudo chmod 600 ~/.smbcredentials
sudo ln -s servicefile.service /etc/systemd/system/servicefile.service
sudo systemctl daemon-reload  
sudo systemctl enable nfsmounts.service
sudo systemctl start nfsmounts.service



**Service erstellen:**

Create your service's unit file with the ".service" suffix in the /etc/systemd/system directory.
In our example, we will be creating a /etc/systemd/system/myservice.service file.

systemd:
`/etc/systemd/system/nfsmounts.service`

Filelocation dotfiles clone, home oder `/usr/local/bin` und symlink:

`nano ~/dotfiles/.mounts/nfsmount-zmbfs-share.service`
`nano /usr/local/bin/nfsmounts.service`

`ln -s ~/dotfiles/.mounts/mount-nfs.service.example /etc/systemd/system/nfsmounts.service`
`ln -s /usr/local/bin/nfsmounts.service /etc/systemd/system/nfsmounts.service`

> :warning: Die entsprechenden mount folder müssen natürlich angelegt werden

`mkdir -d /mnt/nfs`
`mkdir -d /mnt/nfs/servername`


**Example Content of nfsmounts.service**
```
[Unit]  
Description=Custom Service to mount NFS
  
[Service]  
Type=oneshot  
ExecStart=/bin/mount -o hard,nolock 192.168.0.XXX:/share/folder /mnt/nfs/servername/folder

[Install]  
WantedBy=multi-user.target  
```

Service registrieren und starten
```
systemctl daemon-reload  
systemctl enable nfsmounts.service
systemctl start nfsmounts.service
```
