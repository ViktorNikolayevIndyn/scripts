#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# Cloudflared Named Tunnel: create/recreate + DNS route
# With optional full cleanup and sysctl tuning for QUIC.
#
# Flags:
#   --deletefirst   : stop+remove unit, delete tunnel (CF), delete DNS (CF API, if token/zone given)
#   --relogin       : force browser auth (refresh cert.pem)
#
# Env:
#   TUN_NAME        : default 1ait-apps
#   DASHBOARD_HOST  : e.g. captain.apps.linkify.cloud
#   APPS_WILDCARD   : e.g. "*.apps.linkify.cloud"
#   LOCAL_CAPTAIN   : origin for dashboard  (default: http://127.0.0.1:80)
#   LOCAL_DEFAULT   : origin for apps       (default: http://127.0.0.1:80)
#   CF_API_TOKEN    : (optional) DNS edit + Tunnel read
#   CF_ZONE_ID      : (optional) Cloudflare Zone ID
#   METRICS_ADDR    : default 127.0.0.1:20242
#   LOGLEVEL        : default info
#   PROTOCOL        : default quic
# ==========================================================

TUN_NAME="${TUN_NAME:-1ait-apps}"
DASHBOARD_HOST="${DASHBOARD_HOST:-captain.linkify.cloud}"
APPS_WILDCARD="${APPS_WILDCARD:-*.linkify.cloud}"
LOCAL_CAPTAIN="${LOCAL_CAPTAIN:-http://127.0.0.1:80}"
LOCAL_DEFAULT="${LOCAL_DEFAULT:-http://127.0.0.1:80}"
CF_API_TOKEN="${CF_API_TOKEN:-}"
CF_ZONE_ID="${CF_ZONE_ID:-}"
METRICS_ADDR="${METRICS_ADDR:-127.0.0.1:20242}"
LOGLEVEL="${LOGLEVEL:-info}"
PROTOCOL="${PROTOCOL:-quic}"

TUN_HOME="/root/cf-tunnels/${TUN_NAME}"
CFG_DIR="${TUN_HOME}/.cloudflared"
CFG_FILE="${CFG_DIR}/config.yml"
SERVICE="cloudflared-${TUN_NAME}.service"

DELETEFIRST="0"
RELOGIN="0"

# helper: run with isolated HOME
cf() { HOME="${TUN_HOME}" cloudflared "$@" ; }

# Cloudflare DNS API helpers (delete)
cf_api_list_dns() {
  local name="$1"
  curl -fsSL -X GET \
    -H "Authorization: Bearer ${CF_API_TOKEN}" \
    -H "Content-Type: application/json" \
    "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/dns_records?name=$(printf %s "$name" | sed 's/*/%2A/g')" || true
}
cf_api_delete_dns_id() {
  local rec_id="$1"
  curl -fsSL -X DELETE \
    -H "Authorization: Bearer ${CF_API_TOKEN}" \
    -H "Content-Type: application/json" \
    "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/dns_records/${rec_id}" >/dev/null || true
}
cf_api_delete_dns_name() {
  local name="$1"
  [[ -n "${CF_API_TOKEN}" && -n "${CF_ZONE_ID}" ]] || { echo "   [DNS API] token/zone missing → skip ${name}"; return; }
  echo "   [DNS API] deleting records for: ${name}"
  local js; js="$(cf_api_list_dns "${name}")" || js="{}"
  echo "${js}" | jq -r '.result[]?.id' 2>/dev/null | while read -r id; do
    [[ -z "$id" ]] && continue
    cf_api_delete_dns_id "$id"
    echo "     removed id=${id}"
  done
}

# args
for a in "${@:-}"; do
  case "$a" in
    --deletefirst) DELETEFIRST="1";;
    --relogin)     RELOGIN="1";;
    *) echo "Unknown arg: $a" >&2; exit 2;;
  esac
done

echo "==> Prereqs"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y >/dev/null
apt-get install -y curl jq ca-certificates lsb-release >/dev/null

# sysctl for QUIC/UDP buffers (quic-go warning killer)
cat >/etc/sysctl.d/99-cloudflared-quic.conf <<'SYS'
net.core.rmem_max=33554432
net.core.rmem_default=33554432
net.core.wmem_max=33554432
net.core.wmem_default=33554432
SYS
sysctl --system >/dev/null || true

# install cloudflared (prefer .deb latest)
if ! command -v cloudflared >/dev/null 2>&1; then
  echo "==> Installing cloudflared"
  TMP_DEB="/tmp/cloudflared.deb"
  curl -fsSL -o "$TMP_DEB" "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb"
  apt-get install -y "$TMP_DEB" >/dev/null
fi

CFLARE_BIN="$(command -v cloudflared)"

# --------------------------- delete first ---------------------------
if [[ "${DELETEFIRST}" = "1" ]]; then
  echo "==> DELETEFIRST: stop & remove systemd"
  systemctl stop "${SERVICE}" 2>/dev/null || true
  systemctl disable "${SERVICE}" 2>/dev/null || true
  rm -f "/etc/systemd/system/${SERVICE}" || true
  systemctl daemon-reload || true

  echo "==> DELETEFIRST: try delete tunnel in CF"
  mkdir -p "${CFG_DIR}"
  # try reuse any cert for auth
  if [[ ! -f "${CFG_DIR}/cert.pem" ]]; then
    for c in "/root/.cloudflared/cert.pem" $(find /root/cf-tunnels -type f -path "*/.cloudflared/cert.pem" 2>/dev/null || true); do
      [[ -f "$c" ]] && cp -f "$c" "${CFG_DIR}/cert.pem" && break
    done
  fi
  set +e
  TID_EXIST="$(cf tunnel list --output json 2>/dev/null | jq -r --arg n "$TUN_NAME" '.[]|select(.name==$n)|.id' | head -n1)"
  set -e
  if [[ -n "${TID_EXIST:-}" ]]; then
    echo "   deleting CF tunnel: ${TUN_NAME} (${TID_EXIST})"
    cf tunnel delete -f "${TUN_NAME}" || true
  else
    echo "   tunnel not found (skip)"
  fi

  echo "==> DELETEFIRST: delete DNS via CF API (if provided)"
  cf_api_delete_dns_name "${DASHBOARD_HOST}"
  cf_api_delete_dns_name "${APPS_WILDCARD}"

  echo "==> DELETEFIRST: wipe ${TUN_HOME}"
  rm -rf "${TUN_HOME}" 2>/dev/null || true
fi

# --------------------------- create / update ---------------------------
echo "==> Prepare HOME ${TUN_HOME}"
install -d -m 700 "${CFG_DIR}"

if [[ "${RELOGIN}" = "1" ]]; then
  echo "==> RELOGIN: removing ${CFG_DIR}/cert.pem"
  rm -f "${CFG_DIR}/cert.pem"
fi

if [[ ! -f "${CFG_DIR}/cert.pem" ]]; then
  echo "==> Browser auth → ${CFG_DIR}/cert.pem"
  HOME="${TUN_HOME}" "${CFLARE_BIN}" login
  [[ -f "${CFG_DIR}/cert.pem" ]] || { echo "ERROR: cert.pem not created"; exit 1; }
else
  echo "==> cert.pem present"
fi

echo "==> Create/resolve tunnel '${TUN_NAME}'"
set +e
TID="$(cf tunnel list --output json 2>/dev/null | jq -r --arg n "$TUN_NAME" '.[]|select(.name==$n)|.id' | head -n1)"
set -e
if [[ -z "${TID:-}" ]]; then
  echo "   creating: ${TUN_NAME}"
  cf tunnel create "${TUN_NAME}" | sed -n '1,120p'
  TID="$(cf tunnel list --output json | jq -r --arg n "$TUN_NAME" '.[]|select(.name==$n)|.id' | head -n1)"
  [[ -n "$TID" ]] || { echo "ERROR: failed to get tunnel ID"; exit 1; }
else
  echo "   exists: ${TUN_NAME} (ID=${TID})"
fi

CRED_JSON="${CFG_DIR}/${TID}.json"
if [[ ! -f "${CRED_JSON}" ]]; then
  echo "==> Create credentials: ${CRED_JSON}"
  cf tunnel credentials create "${TID}"
  [[ -f "${CRED_JSON}" ]] || { echo "ERROR: credentials not created"; exit 1; }
else
  echo "==> credentials present"
fi

echo "==> Write config: ${CFG_FILE}"
cat > "${CFG_FILE}" <<EOF
tunnel: ${TID}
credentials-file: ${CRED_JSON}
metrics: ${METRICS_ADDR}
protocol: ${PROTOCOL}
no-autoupdate: true
loglevel: ${LOGLEVEL}

ingress:
  - hostname: ${DASHBOARD_HOST}
    service: ${LOCAL_CAPTAIN}
  - hostname: "${APPS_WILDCARD}"
    service: ${LOCAL_DEFAULT}
  - service: http_status:404
EOF

echo "==> DNS route (will create proxied CNAMEs to cfargotunnel)"
set +e
cf tunnel route dns "${TUN_NAME}" "${DASHBOARD_HOST}"
cf tunnel route dns "${TUN_NAME}" "${APPS_WILDCARD}"
set -e

UNIT="/etc/systemd/system/${SERVICE}"
CFLARE_BIN_ESC="${CFLARE_BIN//\//\\/}"
echo "==> systemd unit: ${UNIT}"
cat > "${UNIT}" <<EOF
[Unit]
Description=Cloudflare Tunnel - ${TUN_NAME}
After=network-online.target
Wants=network-online.target

[Service]
Environment=HOME=${TUN_HOME}
ExecStart=${CFLARE_BIN} --config ${CFG_FILE} tunnel run ${TUN_NAME}
Restart=always
RestartSec=2
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now "${SERVICE}"

echo
echo "==> Quick checks"
echo "  - cloudflared --version"
cloudflared --version || true
echo "  - tunnel list"
HOME="${TUN_HOME}" cloudflared tunnel list || true
echo "  - DNS (may need a minute to issue edge cert):"
dig +short CNAME "${DASHBOARD_HOST}" || true
dig +short CNAME "${APPS_WILDCARD}" || true

echo "  - Origin health (local):"
curl -sS -I "${LOCAL_CAPTAIN}" | head -n1 || true
curl -sS -I "${LOCAL_DEFAULT}" | head -n1 || true

echo "  - CF edge health (external via tunnel):"
curl -sS -I "https://${DASHBOARD_HOST}" | head -n5 || true

echo
echo "🎉 Done"
echo "🆔 Tunnel ID : ${TID}"
echo "🏠 HOME      : ${TUN_HOME}"
echo "🗂 Config    : ${CFG_FILE}"
echo "🔏 Creds     : ${CRED_JSON}"
echo "📌 CNAME     : ${TID}.cfargotunnel.com"
echo "🌐 Hosts     : ${DASHBOARD_HOST}, ${APPS_WILDCARD}"
