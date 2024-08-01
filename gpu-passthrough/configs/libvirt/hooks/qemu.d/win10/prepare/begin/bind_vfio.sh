#!/bin/bash

set -x

exec > >(tee -a /tmp/vm_start.log) 2>&1

echo "Starting VM preparation script"

# 1. Load configuration file
if [ -f "/etc/libvirt/hooks/kvm.conf" ]; then
    source "/etc/libvirt/hooks/kvm.conf"
    echo "Configuration file loaded successfully"
else
    echo "Error: Configuration file not found"
    exit 1
fi

# Check if required variables are set
if [ -z "$VIRSH_GPU_VIDEO" ] || [ -z "$VIRSH_GPU_AUDIO" ]; then
    echo "Error: Required variables not set in configuration file"
    exit 1
fi

# 2. Check for NVIDIA modules
nvidia_modules=(nvidia_drm nvidia_modeset nvidia_uvm nvidia)
loaded_nvidia_modules=()

for module in "${nvidia_modules[@]}"; do
    if lsmod | grep -q "$module"; then
        loaded_nvidia_modules+=("$module")
    fi
done

if [ ${#loaded_nvidia_modules[@]} -gt 0 ]; then
    echo "Loaded NVIDIA modules: ${loaded_nvidia_modules[*]}"
else
    echo "No NVIDIA modules currently loaded"
fi

# 3. Check for VFIO modules
vfio_modules=(vfio vfio_iommu_type1 vfio_pci)
loaded_vfio_modules=()

for module in "${vfio_modules[@]}"; do
    if lsmod | grep -q "$module"; then
        loaded_vfio_modules+=("$module")
    fi
done

if [ ${#loaded_vfio_modules[@]} -gt 0 ]; then
    echo "Loaded VFIO modules: ${loaded_vfio_modules[*]}"
else
    echo "No VFIO modules currently loaded"
fi

# 4. Unload NVIDIA modules if loaded
for module in "${loaded_nvidia_modules[@]}"; do
    if ! modprobe -r "$module"; then
        echo "Error: Failed to unload $module"
        exit 1
    fi
done

echo "NVIDIA modules unloaded successfully"

# 5. Load VFIO modules if not already loaded
for module in "${vfio_modules[@]}"; do
    if ! lsmod | grep -q "$module"; then
        if ! modprobe "$module"; then
            echo "Error: Failed to load $module"
            exit 1
        fi
    fi
done

echo "VFIO modules loaded successfully"

# 6. Detach GPU
for dev in $VIRSH_GPU_VIDEO $VIRSH_GPU_AUDIO; do
    if ! virsh nodedev-detach "$dev"; then
        echo "Error: Failed to detach $dev"
        exit 1
    fi
done

echo "GPU detached successfully"

# 7. Wait for changes to take effect
sleep 5

# 8. Verify if devices are successfully bound to VFIO
if lspci -nnk | grep -i nvidia | grep -q 'Kernel driver in use: vfio-pci'; then
    echo "GPU successfully bound to VFIO"
else
    echo "Error: Failed to bind GPU to VFIO"
    lspci -nnk | grep -i nvidia -A3
    exit 1
fi

echo "VM preparation script completed successfully"
