#!/usr/bin/env bash
# Menguji ISO di QEMU.
#   ./test-vm.sh live      boot ISO sebagai live system
#   ./test-vm.sh install   boot ISO + disk virtual kosong (jalankan installer)
#   ./test-vm.sh disk      boot dari disk hasil instalasi
set -euo pipefail
cd "$(dirname "$0")"

ISO="out/kontaineros-1.0-amd64.iso"
DISK="out/test-disk.qcow2"
MODE="${1:-live}"

COMMON=(-m 4096 -smp 2 -vga virtio -nic user,model=virtio-net-pci)
[ -w /dev/kvm ] && COMMON+=(-enable-kvm -cpu host)

case "$MODE" in
live)
	exec qemu-system-x86_64 "${COMMON[@]}" -cdrom "$ISO" -boot d
	;;
install)
	[ -f "$DISK" ] || qemu-img create -f qcow2 "$DISK" 20G
	exec qemu-system-x86_64 "${COMMON[@]}" -cdrom "$ISO" -drive file="$DISK",format=qcow2,if=virtio -boot d
	;;
disk)
	exec qemu-system-x86_64 "${COMMON[@]}" -drive file="$DISK",format=qcow2,if=virtio -boot c
	;;
*)
	echo "Pemakaian: $0 {live|install|disk}" >&2
	exit 1
	;;
esac
