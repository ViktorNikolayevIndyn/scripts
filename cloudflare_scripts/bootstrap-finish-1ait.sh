#!/usr/bin/env bash
set -Eeuo pipefail

# ---------- Settings ----------
TUNNEL_NAME="${TUNNEL_NAME:-linkify-apps}"
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

mkdir -p "${CLOUD_DIR}"

echo "==> Ensure local cert at ${CLOUD_DIR}/cert.pem"
if [[ ! -f "${CLOUD_DIR}/cert.pem" ]]; then
  if [[ -f "/root/.cloudflared/cert.pem" ]]; then
    mv -f /root/.cloudflared/cert.pem "${CLOUD_DIR}/cert.pem"
    chmod 600 "${CLOUD_DIR}/cert.pem"
    echo "   Moved global cert to local tunnel dir."
  else
    echo "   No cert found. Run: ${CLOUDFLARED_BIN} login  (and re-run this script)."
    exit 1
  fi
else
  echo "   Local cert exists."
fi

echo "==> Resolve/create tunnel '${TUNNEL_NAME}'"
TID="$(${CLOUDFLARED_BIN} tunnel list 2>/dev/null | awk -v n="${TUNNEL_NAME}" '$2==n{print $1; exit}')"
if [[ -z "${TID}" ]]; then
  echo "   Creating tunnel..."
  TID="$(${CLOUDFLARED_BIN} --origincert "${CLOUD_DIR}/cert.pem" tunnel create "${TUNNEL_NAME}" | awk '/Created tunnel/ {print $NF}')"
fi
[[ -z "${TID}" ]] && { echo "   Tunnel ID not obtained. Abort."; exit 1; }
echo "   TID=${TID}"

echo "==> Write ${CFG}"
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

# DNS helper via CF API if token is provided (optional)
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
  [[ -z "$zid" ]] && { echo "   CF API: zone not found -> ${zone}"; return 1; }
  # delete existing CNAMEs with same name
  cf_api GET "https://api.cloudflare.com/client/v4/zones/${zid}/dns_records?type=CNAME&name=${host}" \
    | jq -r '.result[].id' | while read -r rid; do
      [[ -n "$rid" ]] && cf_api DELETE "https://api.cloudflare.com/client/v4/zones/${zid}/dns_records/${rid}" >/dev/null || true
    done
  cf_api POST "https://api.cloudflare.com/client/v4/zones/${zid}/dns_records" \
    "$(jq -nc --arg type CNAME --arg name "$host" --arg content "$target" --argjson proxied true \
      '{type:$type,name:$name,content:$content,proxied:$proxied,ttl:1}')"
  echo "   CF API: set CNAME ${host} → ${target}"
}

echo "==> DNS wiring"
BASE_ZONE="${ROOT_DOMAIN#*.}"            # apps.1ait.eu -> 1ait.eu
TUN_TARGET="${TID}.cfargotunnel.com"

if [[ -n "${CF_API_TOKEN:-}" ]]; then
  add_cname_api "${BASE_ZONE}" "${CAPTAIN_HOST}" "${TUN_TARGET}" || true
  add_cname_api "${BASE_ZONE}" "${DEV_HOST}"     "${TUN_TARGET}" || true
  add_cname_api "${BASE_ZONE}" "*.${ROOT_DOMAIN}" "${TUN_TARGET}" || true
else
  echo "   No CF_API_TOKEN -> using 'cloudflared tunnel route dns' (must be logged into proper CF account)"
  ${CLOUDFLARED_BIN} tunnel route dns "${TUNNEL_NAME}" "${CAPTAIN_HOST}" || true
  ${CLOUDFLARED_BIN} tunnel route dns "${TUNNEL_NAME}" "${DEV_HOST}"     || true
  ${CLOUDFLARED_BIN} tunnel route dns "${TUNNEL_NAME}" "*.${ROOT_DOMAIN}" || true
fi

echo "==> systemd unit ${SERVICE}"
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

echo
echo "DONE."
echo "Tunnel:  ${TUNNEL_NAME} (ID=${TID})"
echo "Config:  ${CFG}"
echo "CNAME:   ${TUN_TARGET}"
echo "Hosts:   ${CAPTAIN_HOST}, ${DEV_HOST}, *.${ROOT_DOMAIN}"
echo "Check:   systemctl status ${SERVICE} --no-pager"
