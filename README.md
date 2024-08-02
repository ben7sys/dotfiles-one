# Dotfiles

This repository contains my personal dotfiles, designed to make a freshly installed system fully operational and to keep all configurations for system, software, and user settings portable.

## Main Purpose

- Quick and consistent setup of a new system
- Portability of configurations
- Collection of frequently used scripts and functions
- Useful aliases

## Included Components

- Configuration file to control packages to be installed
- Mount script for SMB and NFS with systemd
- GPU passthrough (config, scripts, libvirt hook)
- Stow for dotfile management
- .bashrc and other basic configurations

## Installation

Current method:
1. Clone the repository:
   ```
   git clone https://github.com/ben7sys/dotfiles.git ~/.dotfiles
   ```
2. Run the setup script:
   ```
   cd ~/.dotfiles
   ./setup.sh
   ```

Future plan:
- A single command via a specific domain that automatically executes everything.

## Compatibility

- Developed on Arch Linux
- Future support for Debian planned

## Customization

You can customize the dotfiles to your needs by:
- Editing `config.sh` (dotfiles_dir, dotfiles_backup_dir, setup_install_packages, stow_source_dir)
- Modifying configuration files in the `.config` folder
- Adjusting systemd mount files

## Special Features

### Mount Script

A functional and user-friendly Bash menu for managing mount points:
- Reads all mount files in the specified folder
- Allows starting, enabling, disabling, and deleting mounts
- Provides a status display for all mounts

Detailed information can be found in the separate README.md of the Mount Script.

## License

These dotfiles are licensed under the [Creative Commons Attribution-NonCommercial (CC BY-NC) License](https://creativecommons.org/licenses/by-nc/4.0/).

You are free to:
- Share and adapt the material

Under the following terms:
- Attribution - You must give appropriate credit.
- NonCommercial - You may not use the material for commercial purposes.
