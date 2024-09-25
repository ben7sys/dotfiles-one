# gpu-passthrough

gpu-passthrough/
├── configs/
│   ├── libvirt/
│   │   ├── hooks/
│   │   │   ├── qemu.d/
│   │   │   │   ├── template_vm/
│   │   │   │   │   ├── prepare/
│   │   │   │   │   │   ├── begin/
│   │   │   │   │   │   │   └── bind_vfio.sh
│   │   │   │   │   ├── release/
│   │   │   │   │   │   ├── end/
│   │   │   │   │   │   │   └── unbind_vfio.sh
│   │   │   │   │   ├── start/
│   │   │   │   │   ├── started/
│   │   │   │   │   └── stopped/
│   │   │   │   ├── win10/
│   │   │   │   │   ├── prepare/
│   │   │   │   │   │   ├── begin/
│   │   │   │   │   │   │   └── bind_vfio.sh
│   │   │   │   │   ├── release/
│   │   │   │   │   │   ├── end/
│   │   │   │   │   │   │   └── unbind_vfio.sh
│   │   │   │   │   ├── start/
│   │   │   │   │   ├── started/
│   │   │   │   │   └── stopped/
│   │   ├── kvm.conf
│   │   ├── qemu
│   │   └── README.md
├── virtio/
│   └── vfio.conf
└── scripts/
    ├── check_gpu_passthrough.sh
    ├── list_all_iommu.sh
    ├── list_iommu.sh
    └── qemu_display_manager.sh


# home

home/
├── .config/
│   ├── autostart/
│   ├── Code - OSS/
│   ├── cronjobs/
│   ├── fastfetch/
│   ├── kde.org/
│   ├── Kvantum/
│   ├── looking-glass/
│   ├── luckybackup/
│   ├── pipewire/
│   ├── plasma-systemmonitor/
│   ├── systemd/
│   ├── conky.conf
│   ├── kdeglobals
│   ├── kwinrulesrc
│   ├── user-dirs.dirs
│   └── user-dirs.locale
├── .local/
│   ├── share/
│   │   ├── applications/
│   │   │   └── looking-glass-client.desktop
│   │   └── fonts/
├── .ssh/
│   └── config
├── .themes/
│   └── Ocean/
├── .aliases
├── .bash_logout
├── .bash_profile
├── .bashrc
├── .dir_colors
├── .env_common
├── .env_kde
├── .env_systemd
├── .exports
├── .functions
├── .gitconfig
├── .gitignore_global
├── .profile
├── .vimrc
├── .zshrc
└── dolphinrc
