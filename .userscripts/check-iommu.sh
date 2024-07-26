#!/bin/bash

# Farbdefinitionen
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Funktion zum Überprüfen des IOMMU-Status
check_iommu() {
    if [ -d /sys/kernel/iommu_groups/ ] && [ "$(ls -A /sys/kernel/iommu_groups/)" ]; then
        echo -e "${GREEN}IOMMU ist aktiviert.${NC}"
        if grep -E "intel_iommu=on|amd_iommu=on" /proc/cmdline > /dev/null; then
            echo -e "${GREEN}IOMMU Kernel-Parameter sind korrekt gesetzt.${NC}"
        else
            echo -e "${YELLOW}IOMMU ist aktiviert, aber die Kernel-Parameter könnten fehlen. Überprüfen Sie Ihre Bootloader-Konfiguration.${NC}"
        fi
    else
        echo -e "${RED}IOMMU ist nicht aktiviert.${NC}"
        echo -e "${YELLOW}Empfehlung: Aktivieren Sie IOMMU in Ihrem BIOS/UEFI und fügen Sie die entsprechenden Kernel-Parameter hinzu:${NC}"
        echo "Für Intel: intel_iommu=on"
        echo "Für AMD: amd_iommu=on"
    fi
}

# Funktion zum Ausgeben aller IOMMU-Gruppen
list_iommu_groups() {
    for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
        echo "IOMMU Group ${g##*/}:"
        for d in $g/devices/*; do
            echo -e "\t$(lspci -nns ${d##*/})"
        done
    done
}

# Funktion zum Auflisten der Grafikkarten-IOMMU-Gruppen
list_gpu_iommu_groups() {
    echo "Grafikkarten IOMMU Gruppen:"
    found_gpu=false
    for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
        group_has_gpu=false
        group_output=""
        for d in $g/devices/*; do
            if [ -e "$d/class" ] && [ "$(cat "$d/class")" = "0x030000" ]; then
                group_has_gpu=true
                found_gpu=true
                group_output+="IOMMU Group ${g##*/}:\n"
                group_output+="\t$(lspci -nns ${d##*/})\n"
                
                # Überprüfen auf zugehörige Audio-Controller
                for a in $g/devices/*; do
                    if [ -e "$a/class" ] && [ "$(cat "$a/class")" = "0x040300" ]; then
                        group_output+="\t$(lspci -nns ${a##*/})\n"
                    fi
                done
            fi
        done
        if $group_has_gpu; then
            echo -e "$group_output"
        fi
    done
    if ! $found_gpu; then
        echo -e "${YELLOW}Keine Grafikkarten in IOMMU-Gruppen gefunden.${NC}"
    fi
}

# Funktion zur Überprüfung der Kernel-Module
check_kernel_modules() {
    echo "Überprüfung der Kernel-Module:"
    modules=("vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd")
    for module in "${modules[@]}"; do
        if lsmod | grep -q "$module"; then
            echo -e "${GREEN}$module ist geladen.${NC}"
        else
            echo -e "${YELLOW}$module ist nicht geladen. Möglicherweise müssen Sie es laden oder in Ihre initramfs aufnehmen.${NC}"
        fi
    done
}

# Hauptprogramm
echo "IOMMU und GPU Passthrough Helper"
echo "================================"

check_iommu
echo

check_kernel_modules
echo

echo "Alle IOMMU Gruppen:"
list_iommu_groups
echo

list_gpu_iommu_groups

# Zusätzliche Informationen und Empfehlungen
echo
echo "Zusätzliche Empfehlungen für GPU-Passthrough:"
echo "1. Stellen Sie sicher, dass die Virtualisierungstechnologie in Ihrem BIOS/UEFI aktiviert ist."
echo "2. Fügen Sie 'vfio vfio_iommu_type1 vfio_pci vfio_virqfd' zu Ihren Kernel-Modulen hinzu."
echo "3. Konfigurieren Sie Ihre VM-Software (z.B. libvirt) für GPU-Passthrough."
echo "4. Beachten Sie mögliche Einschränkungen durch Ihr Motherboard oder Ihre CPU bezüglich IOMMU-Gruppierungen."
