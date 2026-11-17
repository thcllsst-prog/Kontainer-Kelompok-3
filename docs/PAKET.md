# Daftar Paket dan Alasan Pemilihan

**Distro:** KontainerOS 1.0, berbasis Debian 12 (bookworm), dibangun dengan Debian live-build.
**Target pengguna:** pengembang yang membangun, menjalankan, dan menguji container di laptop/VM.

## Paket yang dipasang (relevan dengan target pengguna)

| Paket | Alasan |
|---|---|
| docker.io | Container engine yang paling umum dipakai developer |
| apparmor | Docker memuat profil `docker-default` lewat `apparmor_parser`; tanpa paket ini `docker run` gagal (paket ini hanya "Recommends") |
| pigz, xz-utils | Dukungan kompresi untuk docker.io (diminta oleh paket tersebut sebagai rekomendasi) |
| docker-compose | Menjalankan aplikasi multi-container dari satu file YAML |
| containerd, runc | Runtime tingkat rendah di bawah Docker; relevan untuk belajar OCI runtime |
| podman | Alternatif daemonless dan rootless; cocok untuk membandingkan arsitektur dengan Docker |
| buildah | Membangun image OCI tanpa daemon |
| skopeo | Menyalin dan memeriksa image antar registry tanpa menjalankannya |
| crun | Runtime OCI ringan yang dipakai podman |
| fuse-overlayfs, slirp4netns, uidmap | Dependensi agar container rootless berjalan (filesystem, jaringan, user namespace) |
| cgroup-tools | Mengamati dan mengatur cgroup, inti isolasi sumber daya container |
| iproute2, bridge-utils, iptables, nftables | Memeriksa network namespace, bridge, dan aturan NAT yang dibuat engine container |
| git, make | Alur kerja developer dan build |
| jq | Mengolah keluaran JSON dari `docker inspect` dan sejenisnya |
| yamllint, shellcheck | Validasi file Compose/YAML dan skrip shell |
| vim, mousepad, tmux, htop | Editor, multiplexer terminal, dan monitor proses/memori |
| firefox-esr | Menguji layanan web yang dijalankan di container |

## Desktop dan dasar sistem

| Paket | Alasan |
|---|---|
| xorg, lightdm, lightdm-gtk-greeter | Display server dan login manager yang ringan |
| xfce4, xfce4-terminal, xfce4-taskmanager, thunar-archive-plugin | Desktop XFCE yang hemat RAM, cocok untuk VM |
| network-manager, network-manager-gnome | Jaringan otomatis, penting untuk menarik image |
| zenity | Dialog sambutan pada skrip first-login |
| librsvg2-bin | Mengubah wallpaper/logo SVG menjadi PNG saat build |
| locales, tzdata | Bahasa Indonesia dan zona waktu Asia/Makassar |
| user-setup | Wajib agar live-config membuat pengguna live `dev` saat boot; tanpa ini login gagal (hanya "Recommends") |
| libpam-systemd, dbus-user-session | Sesi login dan layanan per-pengguna yang dipakai desktop |

## Yang dihapus / tidak dipasang

| Item | Alasan |
|---|---|
| `--apt-recommends false` | Mencegah paket rekomendasi ikut terpasang; ukuran ISO lebih kecil |
| xterm | Sudah ada xfce4-terminal |
| reportbug, popularity-contest | Pelaporan/telemetri tidak diperlukan |
| tasksel, tasksel-data, installation-report | Tidak dipakai; instalasi lewat installer live |
| memtest | Dinonaktifkan (`--memtest none`) agar menu boot lebih ringkas |
| Office suite, media player, game | Tidak relevan untuk developer container |

## Catatan: dampak `--apt-recommends false`

Opsi ini menjaga ukuran ISO kecil, tetapi paket yang hanya berstatus "Recommends" tidak ikut terpasang.
Dua kasus nyata yang ditemukan saat pengujian di VirtualBox, dan diperbaiki dengan menuliskan paketnya secara eksplisit:

1. **Login live gagal**: paket `user-setup` tidak terpasang sehingga pengguna `dev` tidak pernah dibuat.
2. **`docker run` gagal**: `apparmor_parser` tidak ada karena paket `apparmor` tidak terpasang.

Pelajaran untuk laporan: setiap kali mematikan rekomendasi, uji fungsi inti (login, menjalankan container) di ISO hasil build.

## Konfigurasi bawaan

- Bahasa `id_ID.UTF-8`, zona waktu `Asia/Makassar`, keyboard `us`.
- Pengguna awal `dev` (grup `sudo` dan `docker`). Pada sesi live kata sandinya `live`; pada instalasi, kata sandi ditanyakan installer.
- Skrip first-login: `/usr/local/bin/kontaineros-firstlogin.sh` (dipicu autostart XFCE, sekali per pengguna). Skrip membuat `~/proyek-container` berisi contoh Dockerfile dan Compose, mencatat versi tool dan keanggotaan grup ke `~/.config/kontaineros/firstlogin.log`, lalu menampilkan dialog sambutan.
