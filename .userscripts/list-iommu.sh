#!/bin/bash

# Check if running as root, otherwise restart with sudo
if [ "$(id -u)" != "0" ]; then
    echo "Restarting script with root privileges..."
    sudo "$0" "$@"
    exit $?
fi

# Check if IOMMU is enabled
if ! dmesg | grep -q 'IOMMU'; then
    echo "IOMMU is not enabled. Please enable it in your BIOS or boot settings."
    exit 1
fi

# Print the IOMMU groups
echo "IOMMU Groups:"
for d in /sys/kernel/iommu_groups/*/devices/*; do
    group=$(echo $d | cut -d '/' -f 6)
    device=$(basename $d)
    printf "IOMMU Group %s - %s\n" "$group" "$(lspci -nns $device)"
done
