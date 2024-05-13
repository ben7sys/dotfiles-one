# dotfiles
my dotfiles

    Technology enthusiast: 🚀 (U+1F680)
    System administration: 🔧 (U+1F527)
    Programming: 💡 (U+1F4A1)
    Automation: 🤖 (U+1F916)
    Ethical: 💎 (U+1F48E)
    Growth: 🌱 (U+1F331)
    Sports: ⚽ (U+26BD)
    Games: 🎮 (U+1F3AE)

    
## Struktur


```sh
.config
.git
.mounts
.safe
.ssh
dev
dotfiles.code-workspace
README.md
```


---


## Todo: Install Skript schreiben

```sh
#!/bin/bash
...
```


--- 


# Befehlssammlung

## Fehlerprüfung

```sh
sudo dmesg | tail
```

## Git Konfiguration

 - Konfiguriere Git, um Merge-Konflikte zu verwenden:

Um immer einen Merge durchzuführen, wenn du git pull ausführst, kannst du Git so konfigurieren, dass es standardmäßig den Merge-Modus verwendet:

```bash
git config --global pull.rebase false
```

Diese Einstellung sorgt dafür, dass Git versucht, die Änderungen zusammenzuführen, und es dir ermöglicht, Merge-Konflikte in einem Editor, wie Visual Studio Code, zu lösen.

 - Visual Studio Code als Standard-Merge-Tool einrichten:

```sh
git config --global core.editor "code --wait"
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd 'code --wait $MERGED'
```


# First steps after fresh debian 12 install

## Install updates

 - hint: Alt+Space > öffnet KRunner > Terminal/Konsole

```sh
sudo apt update
sudo apt upgrade
sudo apt dist-upgrade
sudo apt full-upgrade
```

## Install Flatpak


```sh
sudo apt install flatpak`
```

_Source: https://flatpak.org/setup/Debian_

If you are running GNOME

`sudo apt install gnome-software-plugin-flatpak`

If you are running KDE

`sudo apt install plasma-discover-backend-flatpak`

Add Flathub Repository

`flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo`

## Get latest Firefox

```
sudo apt remove firefox-esr
flatpak install flathub org.mozilla.firefox
```


## Only Office Installation

### First Remove LibreOffice

`sudo apt autopurge libreoffice*`


https://helpcenter.onlyoffice.com/installation/desktop-install-flatpak.aspx

`flatpak install flathub org.onlyoffice.desktopeditors`

```
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```

## Brave Browser

```sh
sudo apt install curl
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/>
sudo apt update
sudo apt install brave-browser -y
```

## DEBIAN AppImageLauncher

 - Manueller Download

!warning: Nochmal überprüfen, es gibt noch weitere projekte

```
https://github.com/TheAssassin/AppImageLauncher/releases/download/v2.2.0/appimagelauncher-lite-2.2.0-travis995-0f91801-x86_64.AppImage
chmod a+x appimagelauncher-lite-*
appimagelauncher-lite-* install
```

### !!! UBUNTU ONLY !!! AppImageLauncher

```sh
sudo apt install python3-launchpadlib software-properties-common
sudo add-apt-repository ppa:appimagelauncher-team/stable
sudo apt update
sudo apt install appimagelauncher
```

### AppImages under ~/Application
 - Cryptomator
 - KeepassXC
 - Obsidian

## Sensoren

```sh
sudo apt install lm-sensors
sudo sensors-detect
sensors
```

## Net-Tools

`sudo apt install net-tools`

## HTOP

`sudo apt install htop`

## Fastfetch (neofetch-like tool)

 - Debian / Ubuntu: Download fastfetch-linux-<proper architecture>.deb from Github release page

Usage: https://github.com/fastfetch-cli/fastfetch?tab=readme-ov-file

`fastfetch ~/.config/fastfetch/*`

## Visual Studio Code

```sh
sudo apt-get install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc>
rm -f packages.microsoft.gpg
sudo apt install apt-transport-https
sudo apt update
sudo apt install code # or code-insiders
```

## Spotify

 - flatpak install `sudo flatpak install flathub com.spotify.Client`

 - apt install

```sh
curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

sudo apt-get update && sudo apt-get install spotify-client -y
```

## KDE

 - Alt + F2 öffnet KRunner

 Eine Suchfeldeingabe erscheint mit der Programme gestartet oder Dateien gesucht werden können (Suchmodule)

## KWallet

 - KWallet in `stock` Debian einrichten

```
Systemeinstellungen > KDE Passwortspeicher
System Settings > KWalletManager
```

## NFS Dienste

```sh
sudo apt install nfs-common
```

## Signal

**NOTE: These instructions only work for 64-bit Debian-based**
**Linux distributions such as Ubuntu, Mint etc.**

 - 1. Install our official public software signing key:

```sh
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
```

 - 2. Add our repository to your list of repositories:

```sh
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
  sudo tee /etc/apt/sources.list.d/signal-xenial.list
```

 - 3. Update your package database and install Signal:
```sh
sudo apt update && sudo apt install signal-desktop
```

## Miniconda

 - **One-Liner**

```bash
mkdir -p ~/miniconda3 && cd ~/miniconda3 && wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh && bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3 && rm -rf ~/miniconda3/miniconda.sh && ~/miniconda3/bin/conda init bash
```

 - Dokumentation https://docs.anaconda.com/free/miniconda/index.html

 - **Miniconda latest Installation and Cleanup:**

```bash
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm -rf ~/miniconda3/miniconda.sh
~/miniconda3/bin/conda init bash
```

 - **Conda-Umgebung erstellen und aktivieren**

`conda create -n myenv python=3.9`

`conda activate myenv`

---

## Custom Grub2 Boot theme

 - Custom Grub2 Boot theme https://github.com/vinceliuice/grub2-themes?tab=readme-ov-file

`git clone https://github.com/vinceliuice/grub2-themes.git`

Verfügbare Displayauflösung: `xrandr`

Open /etc/default/grub, and edit GRUB_GFXMODE=[height]x[width]x32 to match your resolution

Finally, run grub-mkconfig -o /boot/grub/grub.cfg to update your grub config

**Custom Background**

```
sudo apt-get update
sudo apt-get install imagemagick
```


Make sure your background matches your resolution

Place your custom background inside the root of the project, and name it background.jpg

Run the installer like normal, but with -s [YOUR_RESOLUTION] and -t [THEME] and -i [ICON]

    Make sure to replace [YOUR_RESOLUTION] with your resolution and [THEME] with the theme

