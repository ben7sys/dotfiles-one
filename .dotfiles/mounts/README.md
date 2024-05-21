# SystemD Service File Share Mount

Manpages systemd.automount https://manpages.debian.org/testing/manpages-de/systemd.automount.5.de.html

- Eine Unit-Konfigurationsdatei, deren Namen in ».automount« endet

- Automount-Units müssen nach dem Selbsteinhängungsverzeichnis, das sie steuern, benannt sein. 
    Beispiel: Der Selbsteinhängepunkt /home/lennart muss in einer Unit-Datei home-lennart.automount konfiguriert sein.

- Für jede Automount-Unit-Datei muss eine passende Einhänge-Unit-Datei (siehe systemd.mount(5) für Details) existieren, die aktiviert wird, wenn auf den Selbsteinhängungspfad zugegriffen wird.

- Beachten Sie, dass Selbsteinhänge-Units unabhängig von der Einhängung selbst sind, daher sollten Sie hier keine After=- oder Requires=-Einhängeabhängigkeiten setzen.

## Anleitung systemd.automount

- Unit-Files erstellen

**Mount File**

```sh
sudo nano home-username.mount
```

```sh
# /home/username/.dotfiles/home-username.mount
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

**Automount File**

```sh
sudo nano home-username.automount
```

```sh
# /home/username/.dotfiles/home-username.automount
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
```

- service aktivieren

```sh
sudo systemctl enable home-username.automount
```


