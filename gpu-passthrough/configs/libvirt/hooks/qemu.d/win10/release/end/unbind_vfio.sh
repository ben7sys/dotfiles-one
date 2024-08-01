#!/bin/bash

# Enable debugging output
set -x

# Log file for debugging
exec > >(tee -a /tmp/vm_stop.log) 2>&1

echo "Starting VM cleanup script"

# Load the config file
if [ -f "/etc/libvirt/hooks/kvm.conf" ]; then
    source "/etc/libvirt/hooks/kvm.conf"
else
    echo "Error: Configuration file not found"
    exit 1
fi

# Function to check if a module is loaded
module_loaded() {
    lsmod | grep -q "$1"
}

# Reattach GPU to host
for dev in $VIRSH_GPU_VIDEO $VIRSH_GPU_AUDIO; do
    if ! virsh nodedev-reattach "$dev"; then
        echo "Error: Failed to reattach $dev"
        exit 1
    fi
done

echo "GPU reattached successfully"

# Unload VFIO modules
vfio_modules=(vfio_pci vfio_iommu_type1 vfio)
for module in "${vfio_modules[@]}"; do
    if module_loaded "$module"; then
        if ! modprobe -r "$module"; then
            echo "Error: Failed to unload $module"
            exit 1
        fi
    fi
done

echo "VFIO modules unloaded successfully"

# Optional: Load NVIDIA modules
nvidia_modules=(nvidia_drm nvidia_modeset nvidia_uvm nvidia)
for module in "${nvidia_modules[@]}"; do
    if ! module_loaded "$module"; then
        if ! modprobe "$module"; then
            echo "Warning: Failed to load $module"
        fi
    fi
done

echo "NVIDIA modules loaded successfully"

# Verify if devices are successfully unbound from VFIO
if ! lspci -nnk | grep -i nvidia | grep -i vfio > /dev/null; then
    echo "GPU successfully unbound from VFIO"
else
    echo "Error: Failed to unbind GPU from VFIO"
    lspci -nnk | grep -i nvidia -A3
    exit 1
fi

echo "VM cleanup script completed successfully"
