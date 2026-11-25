#!/usr/bin/env bash
# KontainerOS - mengumpulkan data pengukuran untuk Tahap 3 (tabel perbandingan).
# Jalankan di sistem hasil INSTALASI, setelah desktop idle sekitar 2 menit dan tanpa aplikasi lain terbuka.
# Pemakaian:  kontaineros-collect-data.sh [berkas-keluaran]
OUT="${1:-$HOME/data-tahap3-kontaineros.txt}"

{
	echo "== Waktu pengukuran: $(date '+%F %T %Z') =="
	echo
	echo "== Sistem =="
	head -3 /etc/os-release
	echo "Kernel: $(uname -r)"
	echo
	echo "== Waktu boot (systemd-analyze) =="
	systemd-analyze 2>&1
	echo
	echo "== Pemakaian RAM saat idle (MiB) =="
	free -m
	echo
	echo "== Pemakaian disk sistem =="
	df -h /
	echo
	echo "== Jumlah paket terpasang (dpkg) =="
	dpkg -l | grep -c '^ii'
	echo
	echo "== Port yang terbuka (listening) =="
	ss -tuln
	echo
	echo "== Versi tool container =="
	docker --version 2>&1
	podman --version 2>&1
} > "$OUT" 2>&1

echo "Data tersimpan di: $OUT"
echo
cat "$OUT"
