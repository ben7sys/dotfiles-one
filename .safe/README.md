# SystemD Service File Share Mount

**anstatt /etc/fstab zu bearbeiten, können ein oder mehrere services, nfs/smb shares mounten**

**Service erstellen:**

systemd:
`/etc/systemd/system/nfsmounts.service`

Filelocation dotfiles clone, home oder `/usr/local/bin` und symlink:

`nano /usr/local/bin/nfsmounts.service`

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
systenctk start nfsmounts.service
```
