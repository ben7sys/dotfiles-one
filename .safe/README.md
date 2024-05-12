# SystemD Service File Share Mount

**anstatt /etc/fstab zu bearbeiten, können ein oder mehrere services, nfs/smb shares mounten**

**Service erstellen:**

Create your service's unit file with the ".service" suffix in the /etc/systemd/system directory.
In our example, we will be creating a /etc/systemd/system/myservice.service file.

systemd:
`/etc/systemd/system/nfsmounts.service`

Filelocation dotfiles clone, home oder `/usr/local/bin` und symlink:
`nano ~/dotfiles/.safe/nfsmount-zmbfs-share.service`
`nano /usr/local/bin/nfsmounts.service`

`ln -s ~/.dotfiles/
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
