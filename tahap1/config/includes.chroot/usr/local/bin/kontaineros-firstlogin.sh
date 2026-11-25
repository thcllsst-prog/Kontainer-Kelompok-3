#!/usr/bin/env bash
# KontainerOS - skrip yang berjalan SEKALI saat pertama kali pengguna login.
# Dipicu oleh /etc/xdg/autostart/kontaineros-firstlogin.desktop
# Penanda selesai: ~/.config/kontaineros/firstlogin.done

set -u

STATE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kontaineros"
FLAG="$STATE_DIR/firstlogin.done"
LOG="$STATE_DIR/firstlogin.log"

[ -f "$FLAG" ] && exit 0
mkdir -p "$STATE_DIR"

{
	echo "== KontainerOS first-login: $(date '+%F %T %Z') =="

	# 1. Workspace contoh: Dockerfile + docker-compose.yml
	WS="$HOME/proyek-container"
	mkdir -p "$WS/hello-web"

	cat > "$WS/hello-web/Dockerfile" <<'EOF'
FROM busybox:stable
RUN mkdir /www && echo '<h1>Halo dari KontainerOS</h1>' > /www/index.html
EXPOSE 8080
CMD ["httpd", "-f", "-p", "8080", "-h", "/www"]
EOF

	cat > "$WS/hello-web/docker-compose.yml" <<'EOF'
services:
  web:
    build: .
    ports:
      - "8080:8080"
EOF

	cat > "$WS/README.txt" <<'EOF'
Selamat datang di KontainerOS!

Coba:
  cd ~/proyek-container/hello-web
  docker-compose up --build        # Docker
  podman build -t hello-web .      # Podman (rootless)

Alias: d=docker, dc=docker-compose, p=podman
EOF

	# 2. Pemeriksaan lingkungan
	echo "-- versi --"
	docker --version 2>&1
	podman --version 2>&1
	echo "-- grup --"
	id -nG
	echo "-- subuid/subgid (untuk podman rootless) --"
	grep "^$USER:" /etc/subuid /etc/subgid 2>&1
} >> "$LOG" 2>&1

# 2b. Cadangan: paksa wallpaper KontainerOS pada semua monitor/workspace yang dikenal xfdesktop
WP=/usr/share/backgrounds/kontaineros/wallpaper.png
if command -v xfconf-query >/dev/null 2>&1 && [ -f "$WP" ]; then
	sleep 3
	for p in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep -E 'last-image$'); do
		xfconf-query -c xfce4-desktop -p "$p" -s "$WP" >/dev/null 2>&1 || true
	done
fi

# 3. Pesan selamat datang
MSG="Selamat datang di KontainerOS, ${USER}!\n\nWorkspace contoh dibuat di ~/proyek-container\nLog pengecekan: ${LOG/#$HOME/~}"
if command -v zenity >/dev/null 2>&1; then
	zenity --info --no-markup --icon-name=kontaineros-logo \
		--title="KontainerOS" --width=380 --text="$(printf '%b' "$MSG")" 2>/dev/null || true
fi

touch "$FLAG"
