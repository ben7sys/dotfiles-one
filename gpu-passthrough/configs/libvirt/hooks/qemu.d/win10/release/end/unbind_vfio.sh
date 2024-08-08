#!/bin/bash

## Load the config file
source "/etc/libvirt/hooks/kvm.conf"

## Unbind gpu from vfio and bind to nvidia
virsh nodedev-reattach $VIRSH_GPU_VIDEO
virsh nodedev-reattach $VIRSH_GPU_AUDIO
#virsh nodedev-reattach $VIRSH_GPU_USB
#virsh nodedev-reattach $VIRSH_GPU_SERIAL
## Unbind ssd from vfio and bind to nvme
#virsh nodedev-reattach $VIRSH_NVME_SSD

## Unload vfio
#modprobe -r vfio_pci
#modprobe -r vfio_iommu_type1
#modprobe -r vfio

# Function to reattach a device to its original driver
reattach_device() {
    if virsh nodedev-reattach "$1"; then
        echo "Successfully reattached $1"
    else
        echo "Failed to reattach $1"
        exit 1
    fi
}

# Reattach GPU and Audio to the original drivers
reattach_device $VIRSH_GPU_VIDEO
reattach_device $VIRSH_GPU_AUDIO

# Reload the necessary modules
sudo modprobe nvidia_uvm
sudo modprobe nvidia
sudo modprobe nvidia_drm
sudo modprobe nouveau
sudo modprobe nvidia_modeset
sudo modprobe snd_hda_intel

# Restart ollama service if needed
if systemctl is-enabled --quiet ollama; then
    sudo systemctl start ollama
fi