#!/bin/bash

## Load the config file
source "/etc/libvirt/hooks/kvm.conf"

## Load vfio
## only uncomment if you do not have mkinitcpio.conf configured
## edit /etc/mkinitcpio.conf
## MODULES=(vfio vfio_iommu_type1 vfio_pci vfio_virqfd)
#modprobe vfio
#modprobe vfio_iommu_type1
#modprobe vfio_pci

## Which software uses nvidia and intel_hda_snd?
# sudo lsof /dev/nvidia* /dev/snd/*

# Stop ollama if it's running
if systemctl is-active --quiet ollama; then
    sudo systemctl stop ollama
fi

# Stop pipewire if it's running
if systemctl --user is-active --quiet pipewire; then
    systemctl --user stop pipewire
fi

# Stop pipewire-pulse if it's running
if systemctl --user is-active --quiet pipewire-pulse; then
    systemctl --user stop pipewire-pulse
fi

# Function to safely remove a module
remove_module() {
    if lsmod | grep "$1" &> /dev/null; then
        sudo modprobe -r "$1" || echo "Failed to remove $1"
    fi
}

# Remove NVIDIA and Intel HDA modules
remove_module nvidia_uvm
remove_module nvidia
remove_module nvidia_drm
remove_module nouveau
remove_module nvidia_modeset
remove_module snd_hda_intel

# Unbind GPU and Audio from NVIDIA driver and bind to vfio-pci
if virsh nodedev-detach $VIRSH_GPU_VIDEO; then
    echo "Successfully detached $VIRSH_GPU_VIDEO"
else
    echo "Failed to detach $VIRSH_GPU_VIDEO"
    exit 1
fi

if virsh nodedev-detach $VIRSH_GPU_AUDIO; then
    echo "Successfully detached $VIRSH_GPU_AUDIO"
else
    echo "Failed to detach $VIRSH_GPU_AUDIO"
    exit 1
fi

# Restart pipewire and pipewire-pulse
systemctl --user restart pipewire pipewire-pulse

# Start looking-glass-client
looking-glass-client -g EGL -C ~/.config/looking-glass/client.ini

## Unbind gpu from nvidia and bind to vfio
#virsh nodedev-detach $VIRSH_GPU_VIDEO
#virsh nodedev-detach $VIRSH_GPU_AUDIO

## Uncomment the following lines if needed
## Unbind usb and serial from nvidia and bind to vfio
#virsh nodedev-detach $VIRSH_GPU_USB
#virsh nodedev-detach $VIRSH_GPU_SERIAL
## Unbind ssd from nvme and bind to vfio
#virsh nodedev-detach $VIRSH_NVME_SSD
