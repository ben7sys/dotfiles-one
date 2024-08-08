#!/bin/bash

echo "=== GPU Passthrough Status ==="

echo -e "\n1. IOMMU Gruppen und GPU-Status:"
for d in /sys/kernel/iommu_groups/*/devices/*; do
  n=${d#*/iommu_groups/*}; n=${n%%/*}
  printf 'IOMMU Group %s: ' "$n"
  lspci -nns "${d##*/}" | grep -E "NVIDIA|AMD/ATI"
done

echo -e "\n2. GPU Treiber:"
lspci -nnk | grep -A3 "NVIDIA|AMD/ATI"

echo -e "\n3. Kernel-Parameter:"
cat /proc/cmdline

echo -e "\n4. VFIO und GPU Module:"
lsmod | grep -E "vfio|nvidia|amdgpu"

echo -e "\n5. VFIO Konfiguration:"
cat /etc/modprobe.d/vfio.conf 2>/dev/null || echo "Keine vfio.conf gefunden"

echo -e "\n6. VM GPU-Konfiguration:"
sudo virsh dumpxml win10 2>/dev/null | grep -A10 "<hostdev.*GPU" || echo "Keine GPU-Konfiguration in VM gefunden"

echo -e "\n7. QEMU-Befehlszeile (GPU-relevante Teile):"
ps aux | grep qemu | grep win10 | grep -oP -- "-device \S*vfio-pci\S*" || echo "Kein laufender QEMU-Prozess mit GPU-Passthrough gefunden"

echo -e "\n8. Libvirt-Status:"
systemctl is-active libvirtd

echo -e "\n9. Letzte relevante Libvirt-Logs:"
sudo journalctl -u libvirtd -n 20 --no-pager | grep -i "error\|failed\|nvidia\|amd" || echo "Keine relevanten Logs gefunden"

echo -e "\n10. Relevante Kernel-Logs:"
sudo dmesg | grep -i "vfio\|iommu\|nvidia\|amd" | tail -n 20 || echo "Keine relevanten Kernel-Logs gefunden"
