# dotfiles
my dotfiles

# First steps after fresh debian 12 install

**Install updates**

Alt+Space Terminal/Konsole

```
sudo apt update
sudo apt upgrade
sudo apt dist-upgrade
sudo apt full-upgrade
```

**Install Flatpak**
 sudo apt install flatpak
 
Source: https://flatpak.org/setup/Debian

If you are running GNOME

`sudo apt install gnome-software-plugin-flatpak`

If you are running KDE

`sudo apt install plasma-discover-backend-flatpak`

Add Flathub Repository
 flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

**Get latest Firefox**
    sudo apt remove firefox-esr
    flatpak install flathub org.mozilla.firefox

**Remove LibreOffice**
    sudo apt autopurge libreoffice*

**Only Office Installation**
    flatpak install flathub org.onlyoffice.desktopeditors



git config --global user.email "you@example.com"
git config --global user.name "Your Name"

---

## Todo: Install Skript schreiben
#!/bin/bash
...

## Brave Browser
sudo apt install curl
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/>
sudo apt update
sudo apt install brave-browser -y

## !!! UBUNTU ONLY !!! AppImageLauncher
sudo apt install python3-launchpadlib software-properties-common
sudo add-apt-repository ppa:appimagelauncher-team/stable
sudo apt update
sudo apt install appimagelauncher

## DEBIAN AppImageLauncher
Manueller Download
https://github.com/TheAssassin/AppImageLauncher/releases/download/v2.2.0/appimagelauncher-lite-2.2.0-travis995-0f91801-x86_64.AppImage
chmod a+x appimagelauncher-lite-
appimagelauncher-lite install

## AppImages under ~/Application
Cryptomator
KeepassXC
Obsidian

## Fehlerprüfung
sudo dmesg | tail

## Sensoren
sudo apt install lm-sensors
sudo sensors-detect
sensors

## Net-Tools
sudo apt install net-tools

## HTOP
sudo apt install htop

## Fastfetch (neofetch-like tool)
Debian / Ubuntu: Download fastfetch-linux-<proper architecture>.deb from Github release page
fastfetch
Usage: https://github.com/fastfetch-cli/fastfetch?tab=readme-ov-file
fastfetch ~/.config/fastfetch/*

## Visual Studio Code
sudo apt-get install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc>
rm -f packages.microsoft.gpg
sudo apt install apt-transport-https
sudo apt update
sudo apt install code # or code-insiders

## Spotify

sudo flatpak install flathub com.spotify.Client

curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

sudo apt-get update && sudo apt-get install spotify-client -y

## KDE
Alt + F2 öffnet KRunner - Eine Suchfeldeingabe erscheint mit der Programme gestartet oder Dateien gesucht werden können (Suchmodule)

## KWallet
KWallet muss beim Stock Debian eingerichtet werden um benutzt werden zu können
Systemeinstellungen KDE Passwortspeicher
System Settings KWalletManager

## NFS Dienste
sudo apt install nfs-common

## Signal

# NOTE: These instructions only work for 64-bit Debian-based
# Linux distributions such as Ubuntu, Mint etc.

# 1. Install our official public software signing key:
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null

# 2. Add our repository to your list of repositories:
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
  sudo tee /etc/apt/sources.list.d/signal-xenial.list

# 3. Update your package database and install Signal:
sudo apt update && sudo apt install signal-desktop