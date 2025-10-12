#!/bin/bash
set -e

# 🔧 Default settings
# --- Placeholders (edit these) ---
TUNNEL_NAME_DEFAULT="<your_tunnel_name>"    # exmple.: "webai"
DOMAIN_DEFAULT="<your_fqdn>"                # exmple.: "webai.1ait.eu"
LOCAL_URL_DEFAULT="<your_local_url>"        # exmple.:  "http://localhost:8080"
CONFIG_DIR="<path_to_cloudflared_dir>"      # exmple.:  "/root/.cloudflared"
CLOUDFLARED_BIN="<path_to_cloudflared_binary>"    # exmple.: "/usr/local/bin/cloudflared"

# 📦 Dependency check & install (apt-based)
check_dependency() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "📦 Installing $1..."
    apt update && apt install -y "$1"
  }
}

echo "🔍 Checking dependencies..."
check_dependency curl
check_dependency jq
check_dependency "$CLOUDFLARED_BIN" || check_dependency cloudflared
check_dependency uuidgen || apt install -y uuid-runtime

mkdir -p "$CONFIG_DIR"

# 🔐 Authentication
if [ ! -f "$CONFIG_DIR/cert.pem" ]; then
  echo "🔐 Launching browser-based authentication..."
  cloudflared login &
  echo "🌐 Waiting for authentication to complete..."
  while [ ! -f "$CONFIG_DIR/cert.pem" ]; do sleep 1; done
  echo "✅ Authentication completed."
else
  echo "✅ Cloudflare is already authenticated."
fi

# 📥 Input
read -p "🔤 Tunnel name [$TUNNEL_NAME_DEFAULT]: " TUNNEL_NAME
TUNNEL_NAME=${TUNNEL_NAME:-$TUNNEL_NAME_DEFAULT}

read -p "🌐 Subdomain (FQDN) [$DOMAIN_DEFAULT]: " DOMAIN
DOMAIN=${DOMAIN:-$DOMAIN_DEFAULT}

read -p "🔁 Local URL [$LOCAL_URL_DEFAULT]: " LOCAL_URL
LOCAL_URL=${LOCAL_URL:-$LOCAL_URL_DEFAULT}

# 🗑 Remove existing tunnel (if any)
if cloudflared tunnel list | grep -q "$TUNNEL_NAME"; then
  read -p "⚠️ Tunnel '$TUNNEL_NAME' already exists. Delete it? [Y/n]: " DELETE
  DELETE=${DELETE:-Y}
  if [[ "$DELETE" =~ ^[Yy]$ ]]; then
    echo "🗑 Deleting tunnel $TUNNEL_NAME..."
    cloudflared tunnel delete "$TUNNEL_NAME" || true
  else
    echo "🚫 Aborted by user."
    exit 0
  fi
fi

# 🔧 Create a new tunnel
echo "🔧 Creating a new tunnel..."
TUNNEL_OUTPUT=$($CLOUDFLARED_BIN tunnel create "$TUNNEL_NAME")

TUNNEL_ID=$(echo "$TUNNEL_OUTPUT" | grep -oP 'Created tunnel .* with id \K[\w-]+')
CREDENTIAL_FILE="$CONFIG_DIR/$TUNNEL_ID.json"

if [ -z "$TUNNEL_ID" ] || [ ! -f "$CREDENTIAL_FILE" ]; then
  echo "❌ Error: Tunnel ID or credentials file not found."
  exit 1
fi

echo "🆔 Tunnel ID: $TUNNEL_ID"

# 💾 Write config.yml
echo "💾 Saving configuration..."
cat > "$CONFIG_DIR/config.yml" <<EOF
tunnel: $TUNNEL_ID
credentials-file: $CREDENTIAL_FILE

ingress:
  - hostname: $DOMAIN
    service: $LOCAL_URL
  - service: http_status:404
EOF

# 🌍 Create/attach DNS record
echo "🌍 Attaching DNS record..."
if ! cloudflared tunnel route dns "$TUNNEL_NAME" "$DOMAIN" 2>&1 | grep -q 'already exists'; then
  echo "✅ DNS record created and linked."
else
  echo "⚠️ DNS CNAME already exists and may be linked to another tunnel."
  echo "❗ Remove it manually in Cloudflare → DNS → $DOMAIN, then re-run the script."
  exit 1
fi

# ⚙️ systemd unit
SERVICE_FILE="/etc/systemd/system/cloudflared-$TUNNEL_NAME.service"

echo "🛠 Creating systemd service..."
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

# 🚀 Autostart
read -p "🤖 Enable autostart on boot? [Y/n]: " AUTOSTART
AUTOSTART=${AUTOSTART:-Y}
if [[ "$AUTOSTART" =~ ^[Yy]$ ]]; then
  echo "✅ Autostart enabled."
else
  systemctl disable "cloudflared-$TUNNEL_NAME.service"
  echo "🚫 Autostart disabled."
fi

# ✅ Done
echo "🎉 Tunnel configured successfully!"
echo "🌐 Domain: https://$DOMAIN"
echo "🗂 Config: $CONFIG_DIR/config.yml"
