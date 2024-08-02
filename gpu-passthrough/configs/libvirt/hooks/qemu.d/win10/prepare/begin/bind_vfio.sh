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

## Unbind gpu from nvidia and bind to vfio
virsh nodedev-detach $VIRSH_GPU_VIDEO
virsh nodedev-detach $VIRSH_GPU_AUDIO

## Uncomment the following lines if needed
## Unbind usb and serial from nvidia and bind to vfio
#virsh nodedev-detach $VIRSH_GPU_USB
#virsh nodedev-detach $VIRSH_GPU_SERIAL
## Unbind ssd from nvme and bind to vfio
#virsh nodedev-detach $VIRSH_NVME_SSD