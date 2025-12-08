#!/usr/bin/env bash
set -Eeuo pipefail

# ========= Settings (можно менять) =========
TUNNEL_NAME="${TUNNEL_NAME:-linkify-cloud}"
ROOT_DOMAIN="${ROOT_DOMAIN:-linkify.cloud}"
CAPTAIN_HOST="captain.${ROOT_DOMAIN}"
DEV_HOST="dev.${ROOT_DOMAIN}"
LOCAL_HTTP="http://127.0.0.1:80"
LOCAL_CAPTAIN="http://127.0.0.1:3000"

CLOUDFLARED_BIN="/usr/local/bin/cloudflared"
BASE_DIR="/root/cf-tunnels/${TUNNEL_NAME}"
CLOUD_DIR="${BASE_DIR}/.cloudflared"
CFG="${CLOUD_DIR}/config.yml"
SERVICE="cloudflared-${TUNNEL_NAME}.service"

# ========= Helpers =========
need(){ command -v "$1" >/dev/null 2>&1 || { echo "Install failed dependency: $1"; exit 1; }; }

say(){ echo -e "$*"; }

cf_api(){
  local method="$1"; shift
  local url="$1"; shift
  local data="${1:-}"
  local hdr=(-H "Authorization: Bearer ${CF_API_TOKEN}" -H "Content-Type: application/json")
  if [[ -n "$data" ]]; then
    curl -fsS -X "$method" "${hdr[@]}" "$url" --data "$data"
  else
    curl -fsS -X "$method" "${hdr[@]}" "$url"
  fi
}

get_zone_id(){
  local zone="$1"
  cf_api GET "https://api.cloudflare.com/client/v4/zones?name=${zone}" | jq -r '.result[0].id // empty'
}

add_cname_api(){
  local zone="$1" host="$2" target="$3"
  local zid; zid="$(get_zone_id "$zone")"
  [[ -z "$zid" ]] && { say "CF API: zone not found -> ${zone}"; return 1; }
  # upsert: удалить старые CNAME с тем же именем
  cf_api GET "https://api.cloudflare.com/client/v4/zones/${zid}/dns_records?type=CNAME&name=${host}" \
    | jq -r '.result[].id' | while read -r rid; do
      [[ -n "$rid" ]] && cf_api DELETE "https://api.cloudflare.com/client/v4/zones/${zid}/dns_records/${rid}" >/dev/null || true
    done
  cf_api POST "https://api.cloudflare.com/client/v4/zones/${zid}/dns_records" \
    "$(jq -nc --arg type CNAME --arg name "$host" --arg content "$target" --argjson proxied true \
      '{type:$type,name:$name,content:$content,proxied:$proxied,ttl:1}')"
  say "CF API: set CNAME ${host} → ${target}"
}

# ========= 0) Apt baseline =========
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y curl ca-certificates gnupg lsb-release jq ufw

# ========= 1) Docker =========
if ! command -v docker >/dev/null 2>&1; then
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    > /etc/apt/sources.list.d/docker.list
  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  systemctl enable --now docker
fi

# ========= 2) CapRover =========
# Открываем нужные порты в UFW (если установлен)
ufw allow 80/tcp || true
ufw allow 443/tcp || true
ufw allow 3000/tcp || true

docker pull caprover/caprover:latest
# Один раз на хосте:
if ! docker ps -a --format '{{.Names}}' | grep -q '^caprover$'; then
  docker run -e MAIN_NODE=true \
    -e CAPROVER_ROOT_DOMAIN="${ROOT_DOMAIN}" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /captain:/captain \
    --name caprover \
    -p 80:80 -p 443:443 -p 3000:3000 \
    --restart=always \
    -d caprover/caprover:latest
fi

# ========= 3) cloudflared =========
if ! command -v ${CLOUDFLARED_BIN} >/dev/null 2>&1; then
  curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o /tmp/cloudflared.deb
  apt-get install -y /tmp/cloudflared.deb
fi

mkdir -p "${CLOUD_DIR}"

# Локальный login (сертификат в локальную папку)
if [[ ! -f "${CLOUD_DIR}/cert.pem" ]]; then
  say "Opening browser auth (local cert at ${CLOUD_DIR}/cert.pem) ..."
  cloudflared login
  # cloudflared кладёт cert.pem в /root/.cloudflared — перетащим в локальный HOME туннеля
  if [[ -f "/root/.cloudflared/cert.pem" ]]; then
    mv -f /root/.cloudflared/cert.pem "${CLOUD_DIR}/cert.pem"
  fi
fi

# ========= 4) Create tunnel (idempotent) =========
# Проверим, есть ли уже туннель с таким именем
TID="$(cloudflared tunnel list 2>/dev/null | awk -v n="$TUNNEL_NAME" '$2==n{print $1; exit}')"
if [[ -z "${TID}" ]]; then
  # создаём под локальным cert.pem
  TID="$(cloudflared --origincert "${CLOUD_DIR}/cert.pem" tunnel create "${TUNNEL_NAME}" | awk '/Created tunnel/ {print $NF}')"
fi
[[ -z "${TID}" ]] && { echo "Tunnel ID not obtained"; exit 1; }

# ========= 5) config.yml =========
cat > "${CFG}" <<YAML
tunnel: ${TID}
credentials-file: ${CLOUD_DIR}/${TID}.json

ingress:
  - hostname: ${CAPTAIN_HOST}
    service: ${LOCAL_CAPTAIN}
  - hostname: ${DEV_HOST}
    service: ${LOCAL_HTTP}
  - hostname: "*.${ROOT_DOMAIN}"
    service: ${LOCAL_HTTP}
  - service: http_status:404
YAML

# ========= 6) DNS =========
BASE_ZONE="${ROOT_DOMAIN#*.}"         # apps.1ait.eu -> 1ait.eu
TUN_TARGET="${TID}.cfargotunnel.com"

if [[ -n "${CF_API_TOKEN:-}" ]]; then
  # API upsert в нужной зоне
  add_cname_api "${BASE_ZONE}" "${CAPTAIN_HOST}" "${TUN_TARGET}" || true
  add_cname_api "${BASE_ZONE}" "${DEV_HOST}"     "${TUN_TARGET}" || true
  add_cname_api "${BASE_ZONE}" "*.${ROOT_DOMAIN}" "${TUN_TARGET}" || true
else
  # Без API — через cloudflared route dns (должен быть логин в правильный аккаунт)
  cloudflared tunnel route dns "${TUNNEL_NAME}" "${CAPTAIN_HOST}" || true
  cloudflared tunnel route dns "${TUNNEL_NAME}" "${DEV_HOST}"     || true
  cloudflared tunnel route dns "${TUNNEL_NAME}" "*.${ROOT_DOMAIN}" || true
fi

# ========= 7) systemd =========
cat > "/etc/systemd/system/${SERVICE}" <<EOF
[Unit]
Description=Cloudflare Tunnel - ${TUNNEL_NAME}
After=network.target docker.service
Wants=docker.service

[Service]
ExecStart=${CLOUDFLARED_BIN} --config ${CFG} --origincert ${CLOUD_DIR}/cert.pem tunnel run ${TUNNEL_NAME}
Restart=always
RestartSec=2
Environment=HOME=${BASE_DIR}

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now "${SERVICE}"

say
say "========= DONE ========="
say "Tunnel:  ${TUNNEL_NAME} (ID=${TID})"
say "Config:  ${CFG}"
say "CNAME →  ${TUN_TARGET}"
say "Hosts:   ${CAPTAIN_HOST}, ${DEV_HOST}, *.${ROOT_DOMAIN}"
say "CapRover first-time URL (via tunnel):  http://${CAPTAIN_HOST}  (первичный визит идёт на 3000 через ingress)"
