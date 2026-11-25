# Log Kontribusi - Kelompok 5 (Distro Pengembang Container)

> Isi tabel ini dengan data anggota yang sebenarnya. Samakan dengan riwayat commit Git (`git log --author`).

## Anggota dan peran

| Nama | NIM | Akun Git | Peran utama |
|---|---|---|---|
| Nurkayla Safitri | 251011005 | thcllsst-prog | Tahap 1: konfigurasi live-build dan build ISO |
| ISI_NAMA_2 | ISI_NIM | ISI_USERNAME_GITHUB | Tahap 2 Bagian A: Buildroot dasar |
| ISI_NAMA_3 | ISI_NIM | ISI_USERNAME_GITHUB | Tahap 2 Bagian B: modifikasi kernel (B3) |

## Rincian kontribusi

| Tanggal | Anggota | Kegiatan | Bukti (commit / berkas) |
|---|---|---|---|
| 13-14 Nov 2026 | Nurkayla Safitri | Menyiapkan konfigurasi live-build (daftar paket, hook branding, locale, skrip first-login) dan membangun ISO pertama di container Debian 12 | 'auto/', 'config/', 'build.sh' |
| 14-15 Nov 2026 | Nurkayla Safitri | Menguji ISO v2 di VirtualBox: boot live, instal ke disk, boot dari disk; menemukan bug paket 'user-setup' dan 'apparmor' | 'docs/PAKET.md' (bagian dampak '--apt-recommends false') |
| 16 Nov 2026 | Nurkayla Safitri | Membangun ISO v3 dengan perbaikan paket, wallpaper, dan skrip 'kontaineros-collect-data.sh' | 'config/package-lists/', 'config/includes.chroot/usr/local/bin/' |
| 18 Nov 2026 | Nurkayla Safitri | Menguji ISO v3 (live, Docker, Podman), membuat repo Github, dan mengunggah konfigurasi Tahap 1 | repositori ini |

## Catatan kendala dan pembelajaran Tahap 1

- Paket yang hanya berstatus "Recommends" tidak terpasang karena `--apt-recommends false`:
  `user-setup` (pengguna live tidak terbentuk) dan `apparmor` (Docker gagal menjalankan container). Lihat `docs/PAKET.md`.
- Build live-build di dalam container Debian 12 lebih andal daripada di Ubuntu host.
  Menghentikan build di tengah jalan lalu melanjutkannya membuat chroot rusak; gunakan `lb clean` lalu bangun ulang.
- Spesifikasi VM kecil (RAM 3 GB) membuat build lambat dan layar VM sempat membeku.

## Penggunaan alat bantu AI (wajib dideklarasikan)

Konfigurasi awal live-build, hook, dan skrip dibuat dengan bantuan Claude (Anthropic).
Anggota kelompok menjalankan build, menguji ISO di VirtualBox, menemukan dan memperbaiki galat
(paket yang hilang, nama monitor wallpaper, dsb.), dan mempelajari tiap berkas untuk demo.
Sesuaikan paragraf ini dengan keadaan yang sebenarnya.
