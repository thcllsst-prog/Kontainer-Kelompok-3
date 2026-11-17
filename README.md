# Tahap 1 - KontainerOS (Distro Pengembang Container)

ISO live + installer berbasis **Debian 12 (bookworm)** yang dibangun dengan **Debian live-build**.
Desktop XFCE, bahasa Indonesia, zona waktu Asia/Makassar, dan perangkat container
(Docker, Podman, Buildah, Skopeo, dll). Daftar paket dan alasannya ada di [docs/PAKET.md](docs/PAKET.md).

## Informasi kelompok

- Kelompok 5, topik: distro pengembang container
- Anggota dan pembagian kerja: [docs/KONTRIBUSI.md](docs/KONTRIBUSI.md)
- Repositori: [**ISI_URL_REPO_DI_SINI**](https://github.com/thcllsst-prog/Kontainer-Kelompok-3)
- ISO hasil build (unduh): **ISI_TAUTAN_DRIVE_DI_SINI**
- SHA256 ISO: **ISI_HASH_DI_SINI** (hasil `sha256sum kontaineros-1.0-amd64.iso`)

## Struktur

```
tahap1/
├── build.sh                 # satu perintah membangun ISO
├── test-vm.sh               # uji ISO di QEMU (live / install / disk)
├── auto/{config,build,clean}
├── config/
│   ├── package-lists/      # daftar paket (base, desktop, container)
│   ├── hooks/live/         # branding, locale, layanan + cleanup
│   ├── includes.chroot/    # file yang disalin ke sistem (skrip first-login, wallpaper, logo, dll)
│   └── includes.installer/ # preseed installer (bahasa, zona waktu, pengguna awal)
└── docs/PAKET.md
```

## Kebutuhan host

- Linux (Ubuntu 22.04/24.04 atau Debian 12), RAM >= 8 GB, disk kosong >= 20 GB untuk build
- Akses internet (mengunduh paket dari deb.debian.org)
- Paket host:

```bash
sudo apt update
sudo apt install live-build debootstrap xorriso squashfs-tools debian-archive-keyring git
# untuk menguji:
sudo apt install qemu-system-x86 qemu-utils
```

> **Catatan Ubuntu:** versi `live-build` bawaan Ubuntu kadang bermasalah saat membangun image Debian.
> Jika build gagal di tahap bootstrap/installer, bangun dari VM atau container **Debian 12**
> (langkah dan perintah di repo sama persis).
>
> live-build wajib dijalankan sebagai root (`build.sh` memakai `sudo` hanya untuk perintah `lb`).

## Membangun ISO dari nol

```bash
git clone <URL-REPO> && cd <REPO>/tahap1
bash build.sh
```

Hasil: `out/kontaineros-1.0-amd64.iso` beserta checksum `.sha256`. Log lengkap di `build.log`.
Build pertama memakan waktu sekitar 20-60 menit tergantung koneksi.

Membersihkan hasil build: `sudo lb clean --purge`.

## Menguji di QEMU

```bash
./test-vm.sh live      # boot sebagai live system (login: pengguna `dev`, sandi `live`)
./test-vm.sh install   # boot ISO dengan disk kosong 20 GB; pilih "Graphical Install"
./test-vm.sh disk      # setelah instalasi selesai, boot dari disk
```

Untuk VirtualBox/VMware: buat VM Linux 64-bit, RAM 4 GB, disk 20 GB, lalu pasang ISO.

## Konfigurasi bawaan

| Item | Nilai |
|---|---|
| Nama distro | KontainerOS 1.0 |
| Bahasa / zona waktu | id_ID.UTF-8 / Asia/Makassar |
| Pengguna awal | `dev` (sudo, docker); sandi live: `live`; pada instalasi sandi ditanyakan installer |
| Skrip first-login | `/usr/local/bin/kontaineros-firstlogin.sh` (sekali per pengguna) |
| Desktop | XFCE + LightDM, wallpaper dan logo kustom |

## Cara build yang sudah teruji (di container Debian 12)

Dijalankan dari Ubuntu dengan Podman. Di dalam container tidak perlu `sudo`, dan `lb build` sudah menulis `build.log` sendiri lewat `auto/build` (jangan ditambah `tee`).

```bash
sudo podman run --rm -it --privileged -v "$PWD":/work -w /work debian:bookworm bash
# di dalam container:
apt update && apt install -y live-build debootstrap xorriso squashfs-tools debian-archive-keyring
bash build.sh   # menjalankan lb clean, lb config, lb build lalu memindahkan ISO ke out/
exit
```

`build.sh` melakukan urutan yang sama dengan perintah manual `lb clean`, `lb config`, `lb build`
dan otomatis memakai `sudo` hanya jika dijalankan bukan sebagai root.

Catatan:
- Jangan menghentikan `lb build` di tengah jalan lalu melanjutkannya; kondisi setengah jadi bisa membuat chroot rusak. Jika perlu mengulang, jalankan `lb clean` (tanpa `--purge`) agar cache paket tetap ada.
- Login sesi live: pengguna `dev`, sandi `live`.
- Spesifikasi yang disarankan: RAM 6 GB atau lebih dan disk kosong 20 GB atau lebih; RAM 3 GB membuat build lambat dan rawan membeku.

## Cek cepat setelah boot

```bash
cat /etc/os-release | head -3
docker --version && podman --version
id                                  # harus ada grup docker
ls ~/proyek-container               # dibuat oleh skrip first-login
cat ~/.config/kontaineros/firstlogin.log
sudo docker run --rm hello-world    # perlu internet
```

## Sumber rujukan

- Debian Live Systems Manual: https://live-team.pages.debian.net/live-manual/
- Debian Installer preseed: https://www.debian.org/releases/bookworm/amd64/apb.en.html
- Dokumentasi Docker dan Podman (podman.io)

## Deklarasi penggunaan AI

Struktur awal konfigurasi live-build, hook, dan skrip dibuat dengan bantuan Claude (Anthropic),
lalu dipelajari dan diuji oleh anggota kelompok. Tulis di laporan, dan pastikan tiap anggota
bisa menjelaskan setiap file saat demo.
