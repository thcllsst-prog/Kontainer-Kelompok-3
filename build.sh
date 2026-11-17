#!/usr/bin/env bash
# Membangun ISO KontainerOS dari repositori bersih.
# Pemakaian:  ./build.sh        (akan meminta sudo; live-build wajib root)
set -euo pipefail
cd "$(dirname "$0")"

MIN_FREE_GB=10

# Pakai sudo hanya jika bukan root (di dalam container Debian skrip ini sudah berjalan sebagai root)
SUDO=""
[ "$(id -u)" -ne 0 ] && SUDO="sudo"

for cmd in lb debootstrap xorriso mksquashfs; do
	command -v "$cmd" >/dev/null 2>&1 || {
		echo "Perintah '$cmd' tidak ditemukan. Pasang dulu:"
		echo "  sudo apt install live-build debootstrap xorriso squashfs-tools debian-archive-keyring"
		exit 1
	}
done

free_gb=$(df -BG --output=avail . | tail -1 | tr -dc '0-9')
if [ "${free_gb:-0}" -lt "$MIN_FREE_GB" ]; then
	echo "Ruang disk kosong ${free_gb}GB, butuh minimal ${MIN_FREE_GB}GB." >&2
	exit 1
fi

chmod +x auto/* config/hooks/live/*.hook.chroot \
	config/includes.chroot/usr/local/bin/kontaineros-firstlogin.sh \
	config/includes.chroot/usr/local/bin/kontaineros-collect-data.sh

# "lb clean" tanpa --purge: membuang chroot lama tetapi mempertahankan cache paket
$SUDO lb clean || true
$SUDO lb config
# auto/build sudah menulis log ke build.log, jadi jangan ditambah tee
$SUDO lb build

mkdir -p out
iso=$(ls -1 ./*.iso 2>/dev/null | head -n1 || true)
if [ -z "$iso" ]; then
	echo "ISO tidak ditemukan, cek build.log" >&2
	exit 1
fi
OWNER="${SUDO_USER:-${USER:-root}}"
$SUDO chown "$OWNER":"$OWNER" "$iso" build.log 2>/dev/null || true
mv "$iso" out/kontaineros-1.0-amd64.iso
(cd out && sha256sum kontaineros-1.0-amd64.iso | tee kontaineros-1.0-amd64.iso.sha256)
echo "Selesai: out/kontaineros-1.0-amd64.iso"
