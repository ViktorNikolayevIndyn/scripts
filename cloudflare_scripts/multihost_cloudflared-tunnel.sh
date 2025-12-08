#!/bin/bash
set -Eeuo pipefail

### ====== НАСТРОЙКИ ПО УМОЛЧАНИЮ (поправь под себя) ======
TUNNEL_NAME_DEFAULT="caprover"
CONFIG_DIR="/root/.cloudflared"
CLOUDFLARED_BIN="/usr/local/bin/cloudflared"

# IP LXC, где запущен CapRover
LXC_IP="{{LXC_IP}}"

# Список хостов:  HOST=SERVICE_URL
# ВАЖНО: кавычки вокруг *.apps... сохраняем (валидный YAML)
HOSTS=(
  "captain.1ait.eu=http://$LXC_IP:3000"     # панель CapRover
  "apps.1ait.de=http://$LXC_IP:80"     # прод-приложение
  "'*.apps.1ait.de'=http://$LXC_IP:80" # wildcard для всех appname.apps.linkify.cloud
)

### ====== ФУНКЦИИ ======
check_dep() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "📦 Installing $1..."
    apt update && apt install -y "$1"
  }
}

ensure_login() {
  mkdir -p "$CONFIG_DIR"
  if [ ! -f "$CONFIG_DIR/cert.pem" ]; then
    echo "🔐 Browser auth..."
    $CLOUDFLARED_BIN login &
    echo "⏳ Waiting for cert.pem..."
    while [ ! -f "$CONFIG_DIR/cert.pem" ]; do sleep 1; done
  fi
}

get_tunnel_id() {
  local name="$1"
  local id
  id="$($CLOUDFLARED_BIN tunnel list 2>/dev/null | awk -v n="$name" '$0 ~ n {print $1}' | head -n1 || true)"
  echo "$id"
}

route_dns() {
  local tname="$1" host="$2"
  # если уже есть — команда вернёт "already exists", что ок
  $CLOUDFLARED_BIN tunnel route dns "$tname" "$host" >/tmp/route.out 2>&1 || true
  if grep -qi "not entitled" /tmp/route.out; then
    echo "❌ Cloudflare: зона для $host не в аккаунте или нет прав."
    echo "   Добавь домен в Cloudflare и повтори."
    exit 1
  fi
}

### ====== ПРОВЕРКИ И ВВОД ======
echo "🔍 Checking dependencies..."
check_dep curl
check_dep jq
[ -x "$CLOUDFLARED_BIN" ] || check_dep cloudflared
command -v uuidgen >/dev/null 2>&1 || apt install -y uuid-runtime

ensure_login

read -p "🔤 Tunnel name [$TUNNEL_NAME_DEFAULT]: " TUNNEL_NAME
TUNNEL_NAME=${TUNNEL_NAME:-$TUNNEL_NAME_DEFAULT}

### ====== ТУННЕЛЬ: СОЗДАТЬ ИЛИ ИСПОЛЬЗОВАТЬ СУЩЕСТВУЮЩИЙ ======
TUNNEL_ID="$(get_tunnel_id "$TUNNEL_NAME")"
if [ -z "$TUNNEL_ID" ]; then
  echo "🔧 Creating tunnel $TUNNEL_NAME..."
  OUT="$($CLOUDFLARED_BIN tunnel create "$TUNNEL_NAME")"
  echo "$OUT"
  TUNNEL_ID="$(echo "$OUT" | grep -oP 'id \K[\w-]+' | head -n1)"
fi

if [ -z "${TUNNEL_ID:-}" ]; then
  echo "❌ Не удалось получить TUNNEL_ID."
  exit 1
fi

CREDENTIAL_FILE="$CONFIG_DIR/$TUNNEL_ID.json"
if [ ! -f "$CREDENTIAL_FILE" ]; then
  echo "❌ Нет файла учётных данных: $CREDENTIAL_FILE"
  exit 1
fi

echo "🆔 TUNNEL_ID: $TUNNEL_ID"

### ====== СБОРКА ingress ======
TMPY="$(mktemp)"
{
  echo "tunnel: $TUNNEL_ID"
  echo "credentials-file: $CREDENTIAL_FILE"
  echo
  echo "ingress:"
  for pair in "${HOSTS[@]}"; do
    host="${pair%%=*}"
    url="${pair#*=}"
    echo "  - hostname: $host"
    echo "    service: $url"
  done
  echo "  - service: http_status:404"
} > "$TMPY"

install -m 600 "$TMPY" "$CONFIG_DIR/config.yml"
rm -f "$TMPY"
echo "💾 Saved: $CONFIG_DIR/config.yml"

### ====== DNS ROUTE ДЛЯ КАЖДОГО ХОСТА ======
for pair in "${HOSTS[@]}"; do
  host="${pair%%=*}"
  # убираем кавычки у wildcard перед route dns
  host_clean="${host//\'}"
  echo "🌍 DNS route: $host_clean"
  route_dns "$TUNNEL_NAME" "$host_clean"
done

### ====== SYSTEMD UNIT ======
SERVICE_FILE="/etc/systemd/system/cloudflared-$TUNNEL_NAME.service"
cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Cloudflare Tunnel - $TUNNEL_NAME
After=network.target

[Service]
TimeoutStartSec=0
ExecStart=$CLOUDFLARED_BIN tunnel run $TUNNEL_NAME
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable "cloudflared-$TUNNEL_NAME.service"
systemctl restart "cloudflared-$TUNNEL_NAME.service"

echo "✅ Tunnel is running."
systemctl --no-pager status "cloudflared-$TUNNEL_NAME.service" | sed -n '1,12p'

echo
echo "🎉 Done."
echo "🔗 Panel:   https://project.1ait.eu"
echo "🔗 App:     https://app.linkify.cloud"
echo "🔗 Wildcard: *.apps.linkify.cloud"
