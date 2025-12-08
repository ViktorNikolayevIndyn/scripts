#!/bin/bash
#
# Cloudflare Tunnel Setup для n8n
# Адаптированная версия для автоматической настройки
#

set -e

# 🔧 Default settings
TUNNEL_NAME_DEFAULT="n8n-tunnel"
LOCAL_URL_DEFAULT="http://localhost:80"
CONFIG_DIR="/root/.cloudflared"
CLOUDFLARED_BIN="/usr/local/bin/cloudflared"
API_TOKEN_FILE="/root/.cloudflare-api-token"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log() {
    echo -e "${CYAN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $*"
}

error() {
    echo -e "${RED}❌ ERROR:${NC} $*" >&2
}

success() {
    echo -e "${GREEN}✅${NC} $*"
}

warning() {
    echo -e "${YELLOW}⚠️${NC} $*"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root"
   exit 1
fi

# 📦 Dependency check & install
check_dependency() {
  local cmd=$1
  local pkg=${2:-$1}
  
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log "Installing $pkg..."
    apt update -qq && apt install -y "$pkg" >/dev/null 2>&1
    if command -v "$cmd" >/dev/null 2>&1; then
      success "$cmd installed"
    else
      error "Failed to install $pkg"
      exit 1
    fi
  fi
}

log "Checking dependencies..."
check_dependency curl
check_dependency jq
check_dependency uuidgen uuid-runtime

# Install cloudflared if not present
if [ ! -f "$CLOUDFLARED_BIN" ]; then
    log "Installing cloudflared..."
    curl -L --output "$CLOUDFLARED_BIN" \
        https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
    chmod +x "$CLOUDFLARED_BIN"
    success "cloudflared installed"
else
    success "cloudflared already installed"
fi

mkdir -p "$CONFIG_DIR"

# 🔐 Authentication Method Selection
echo ""

USE_API=false
CF_API_TOKEN=""
CF_ACCOUNT_ID=""

# Check for saved API token
if [ -f "$API_TOKEN_FILE" ]; then
    CF_API_TOKEN=$(cat "$API_TOKEN_FILE")
    log "Found saved API Token"
    USE_API=true
    
    echo ""
    read -p "Use saved API Token? [Y/n]: " USE_SAVED
    USE_SAVED=${USE_SAVED:-Y}
    
    if [[ ! "$USE_SAVED" =~ ^[Yy]$ ]]; then
        CF_API_TOKEN=""
        USE_API=false
    fi
fi

# If no saved token or user declined, ask for method
if [ -z "$CF_API_TOKEN" ]; then
    log "Choose authentication method:"
    echo "1. Cloudflare API Token (recommended for headless servers)"
    echo "2. Browser login (cloudflared login)"
    echo ""
    read -p "Select method [1/2]: " AUTH_METHOD
    AUTH_METHOD=${AUTH_METHOD:-1}

    if [ "$AUTH_METHOD" = "1" ]; then
        # API Token method
        USE_API=true
        echo ""
        log "Using Cloudflare API authentication"
        echo ""
        echo "Get your API Token from:"
        echo "https://dash.cloudflare.com/profile/api-tokens"
        echo ""
        echo "Token permissions needed:"
        echo "  - Account → Cloudflare Tunnel → Edit"
        echo "  - Zone → DNS → Edit"
        echo ""
        read -p "Enter Cloudflare API Token: " CF_API_TOKEN
        
        if [ -z "$CF_API_TOKEN" ]; then
            error "API Token is required"
            exit 1
        fi
        
        # Ask to save token
        echo ""
        read -p "Save API Token for future use? [Y/n]: " SAVE_TOKEN
        SAVE_TOKEN=${SAVE_TOKEN:-Y}
        
        if [[ "$SAVE_TOKEN" =~ ^[Yy]$ ]]; then
            echo "$CF_API_TOKEN" > "$API_TOKEN_FILE"
            chmod 600 "$API_TOKEN_FILE"
            success "API Token saved to $API_TOKEN_FILE"
        fi
    fi
fi

# Verify API token if using API method
if [ "$USE_API" = true ] && [ -n "$CF_API_TOKEN" ]; then
    
    # Test API connection by fetching accounts
    log "Testing API connection..."
    
    # Get Account ID
    log "Fetching account information..."
    ACCOUNTS_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts" \
        -H "Authorization: Bearer $CF_API_TOKEN" \
        -H "Content-Type: application/json")
    
    API_SUCCESS=$(echo "$ACCOUNTS_RESPONSE" | jq -r '.success // false')
    
    if [ "$API_SUCCESS" != "true" ]; then
        error "Could not fetch account ID. Check your API token permissions."
        echo "$ACCOUNTS_RESPONSE" | jq '.'
        exit 1
    fi
    
    CF_ACCOUNT_ID=$(echo "$ACCOUNTS_RESPONSE" | jq -r '.result[0].id // empty')
    ACCOUNT_NAME=$(echo "$ACCOUNTS_RESPONSE" | jq -r '.result[0].name // empty')
    
    log "Account: $ACCOUNT_NAME"
    log "Account ID: $CF_ACCOUNT_ID"
    success "✓ API authentication successful"
    
    # Check tunnel permissions
    log "Verifying tunnel permissions..."
    TUNNEL_PERMS_CHECK=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/cfd_tunnel" \
        -H "Authorization: Bearer $CF_API_TOKEN" \
        -H "Content-Type: application/json")
    
    PERMS_SUCCESS=$(echo "$TUNNEL_PERMS_CHECK" | jq -r '.success // false')
    
    if [ "$PERMS_SUCCESS" != "true" ]; then
        error "API Token does not have Cloudflare Tunnel permissions"
        echo ""
        echo "Please create a new API Token with these permissions:"
        echo "  1. Go to: https://dash.cloudflare.com/profile/api-tokens"
        echo "  2. Create Token → Custom Token"
        echo "  3. Add permissions:"
        echo "     • Account → Cloudflare Tunnel → Edit"
        echo "     • Zone → DNS → Edit"
        echo "  4. Save the token and run this script again"
        echo ""
        exit 1
    fi
    
    success "✓ Tunnel permissions verified"
    
elif [ "$AUTH_METHOD" = "2" ]; then
    # Browser login method
    if [ ! -f "$CONFIG_DIR/cert.pem" ]; then
        echo ""
        warning "Cloudflare authentication required!"
        log "Opening browser for authentication..."
        echo ""
        echo "Please follow these steps:"
        echo "1. A browser window will open"
        echo "2. Log in to your Cloudflare account"
        echo "3. Authorize the tunnel"
        echo ""
        read -p "Press Enter to continue..."
        
        "$CLOUDFLARED_BIN" login &
        
        log "Waiting for authentication..."
        TIMEOUT=300  # 5 minutes timeout
        ELAPSED=0
        while [ ! -f "$CONFIG_DIR/cert.pem" ]; do
            sleep 2
            ELAPSED=$((ELAPSED + 2))
            if [ $ELAPSED -gt $TIMEOUT ]; then
                error "Authentication timeout. Please try again."
                exit 1
            fi
        done
        success "Authentication completed"
    else
        success "Already authenticated with Cloudflare"
    fi
else
    error "Invalid selection"
    exit 1
fi

# 🧹 Check and remove old cloudflared service
echo ""
log "Checking for old cloudflared services..."

OLD_SERVICES=("cloudflared" "cloudflared.service")
SERVICES_REMOVED=false

for SERVICE_NAME in "${OLD_SERVICES[@]}"; do
    if systemctl list-units --full --all | grep -q "$SERVICE_NAME"; then
        warning "Found old service: $SERVICE_NAME"
        log "Stopping $SERVICE_NAME..."
        systemctl stop "$SERVICE_NAME" 2>/dev/null || true
        log "Disabling $SERVICE_NAME..."
        systemctl disable "$SERVICE_NAME" 2>/dev/null || true
        
        # Remove service file
        SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME"
        if [ -f "$SERVICE_FILE" ]; then
            log "Removing $SERVICE_FILE..."
            rm -f "$SERVICE_FILE"
            SERVICES_REMOVED=true
        fi
        
        success "✓ Removed old service: $SERVICE_NAME"
    fi
done

if [ "$SERVICES_REMOVED" = true ]; then
    log "Reloading systemd daemon..."
    systemctl daemon-reload
    success "✓ Old services cleaned up"
else
    log "No old cloudflared services found"
fi

# 📥 Input
echo ""
log "Tunnel Configuration"
echo ""

# Check if .env exists and load defaults
N8N_HOST_DEFAULT=""
USE_ENV_DEFAULTS=false

# Try multiple possible locations
ENV_LOCATIONS=(
    "/opt/n8n/.env"
    "$N8N_DIR/.env"
    "$(dirname "$0")/.env"
    ".env"
)

ENV_FILE=""
for location in "${ENV_LOCATIONS[@]}"; do
    if [ -f "$location" ]; then
        ENV_FILE="$location"
        break
    fi
done

if [ -n "$ENV_FILE" ] && [ -f "$ENV_FILE" ]; then
    log "Found existing .env at: $ENV_FILE"
    read -p "Use domain from .env as default? [Y/n]: " USE_ENV
    USE_ENV=${USE_ENV:-Y}
    
    if [[ "$USE_ENV" =~ ^[Yy]$ ]]; then
        # Load N8N_HOST from .env
        N8N_HOST_DEFAULT=$(grep "^N8N_HOST=" "$ENV_FILE" | cut -d'=' -f2 | tr -d '"' | tr -d "'" | sed 's/^https\?:\/\///')
        USE_ENV_DEFAULTS=true
        if [ -n "$N8N_HOST_DEFAULT" ]; then
            success "Loaded domain from .env: $N8N_HOST_DEFAULT"
        else
            warning ".env found but N8N_HOST not set"
        fi
    fi
else
    log "No .env file found (checked: ${ENV_LOCATIONS[*]})"
fi

read -p "🔤 Tunnel name [$TUNNEL_NAME_DEFAULT]: " TUNNEL_NAME
TUNNEL_NAME=${TUNNEL_NAME:-$TUNNEL_NAME_DEFAULT}

if [ "$USE_ENV_DEFAULTS" = true ] && [ -n "$N8N_HOST_DEFAULT" ]; then
    read -p "🌐 Your domain [$N8N_HOST_DEFAULT]: " DOMAIN
    DOMAIN=${DOMAIN:-$N8N_HOST_DEFAULT}
else
    read -p "🌐 Your domain (e.g., n8n.example.com): " DOMAIN
fi

if [ -z "$DOMAIN" ]; then
    error "Domain is required!"
    exit 1
fi

read -p "🔁 Local URL [$LOCAL_URL_DEFAULT]: " LOCAL_URL
LOCAL_URL=${LOCAL_URL:-$LOCAL_URL_DEFAULT}

# 🗑 Remove existing tunnel (if any)
if [ "$USE_API" = false ]; then
    # Check existing tunnel via CLI
    if "$CLOUDFLARED_BIN" tunnel list 2>/dev/null | grep -q "$TUNNEL_NAME"; then
      warning "Tunnel '$TUNNEL_NAME' already exists"
      read -p "Delete and recreate? [Y/n]: " DELETE
      DELETE=${DELETE:-Y}
      if [[ "$DELETE" =~ ^[Yy]$ ]]; then
        log "Deleting existing tunnel..."
        "$CLOUDFLARED_BIN" tunnel delete "$TUNNEL_NAME" 2>/dev/null || true
        success "Old tunnel deleted"
      else
        log "Using existing tunnel..."
        TUNNEL_ID=$("$CLOUDFLARED_BIN" tunnel list | grep "$TUNNEL_NAME" | awk '{print $1}')
      fi
    fi
else
    # Check existing tunnel via API
    TUNNELS_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/cfd_tunnel" \
        -H "Authorization: Bearer $CF_API_TOKEN" \
        -H "Content-Type: application/json")
    
    # Check if result exists and is an array
    if echo "$TUNNELS_RESPONSE" | jq -e '.result' >/dev/null 2>&1; then
        # Get all tunnel IDs with this name
        EXISTING_TUNNEL_IDS=$(echo "$TUNNELS_RESPONSE" | jq -r ".result[]? | select(.name == \"$TUNNEL_NAME\") | .id")
    else
        EXISTING_TUNNEL_IDS=""
    fi
    
    if [ -n "$EXISTING_TUNNEL_IDS" ]; then
        # Count tunnels
        TUNNEL_COUNT=$(echo "$EXISTING_TUNNEL_IDS" | wc -l)
        
        if [ "$TUNNEL_COUNT" -gt 1 ]; then
            warning "Found $TUNNEL_COUNT tunnels with name '$TUNNEL_NAME'"
            echo "$EXISTING_TUNNEL_IDS" | while read -r tid; do
                log "  - ID: $tid"
            done
        else
            warning "Tunnel '$TUNNEL_NAME' already exists (ID: $EXISTING_TUNNEL_IDS)"
        fi
        
        read -p "Delete all and recreate? [Y/n]: " DELETE
        DELETE=${DELETE:-Y}
        if [[ "$DELETE" =~ ^[Yy]$ ]]; then
            log "Deleting existing tunnel(s)..."
            echo "$EXISTING_TUNNEL_IDS" | while read -r tid; do
                if [ -n "$tid" ]; then
                    log "Deleting tunnel $tid..."
                    curl -s -X DELETE "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/cfd_tunnel/$tid" \
                        -H "Authorization: Bearer $CF_API_TOKEN" \
                        -H "Content-Type: application/json" > /dev/null
                fi
            done
            success "Old tunnel(s) deleted"
            log "Waiting 3 seconds for Cloudflare API to propagate changes..."
            sleep 3
        else
            log "Using first existing tunnel..."
            TUNNEL_ID=$(echo "$EXISTING_TUNNEL_IDS" | head -n1)
        fi
    fi
fi

# 🚇 Create tunnel if needed
if [ -z "$TUNNEL_ID" ]; then
    log "Creating new tunnel '$TUNNEL_NAME'..."
    
    if [ "$USE_API" = true ]; then
        # Create tunnel via API
        TUNNEL_SECRET=$(openssl rand -base64 32)
        TUNNEL_RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/cfd_tunnel" \
            -H "Authorization: Bearer $CF_API_TOKEN" \
            -H "Content-Type: application/json" \
            --data "{\"name\":\"$TUNNEL_NAME\",\"tunnel_secret\":\"$TUNNEL_SECRET\"}")
        
        # Check if API call was successful
        API_SUCCESS=$(echo "$TUNNEL_RESPONSE" | jq -r '.success // false')
        
        if [ "$API_SUCCESS" != "true" ]; then
            error "Failed to create tunnel via API"
            echo "$TUNNEL_RESPONSE" | jq '.'
            exit 1
        fi
        
        TUNNEL_ID=$(echo "$TUNNEL_RESPONSE" | jq -r '.result.id // empty')
        
        if [ -z "$TUNNEL_ID" ]; then
            error "Failed to extract tunnel ID from response"
            echo "Response: $TUNNEL_RESPONSE"
            exit 1
        fi
        
        # Save tunnel credentials
        TUNNEL_CREDS="{\"AccountTag\":\"$CF_ACCOUNT_ID\",\"TunnelSecret\":\"$TUNNEL_SECRET\",\"TunnelID\":\"$TUNNEL_ID\"}"
        echo "$TUNNEL_CREDS" > "$CONFIG_DIR/$TUNNEL_ID.json"
        chmod 600 "$CONFIG_DIR/$TUNNEL_ID.json"
        
    else
        # Create tunnel via CLI
        TUNNEL_OUTPUT=$("$CLOUDFLARED_BIN" tunnel create "$TUNNEL_NAME" 2>&1)
        
        TUNNEL_ID=$(echo "$TUNNEL_OUTPUT" | grep -oP 'Created tunnel .* with id \K[\w-]+')
        
        if [ -z "$TUNNEL_ID" ]; then
            error "Failed to create tunnel"
            echo "$TUNNEL_OUTPUT"
            exit 1
        fi
    fi
    
    success "Tunnel created with ID: $TUNNEL_ID"
fi

CREDENTIAL_FILE="$CONFIG_DIR/$TUNNEL_ID.json"

if [ ! -f "$CREDENTIAL_FILE" ]; then
  error "Credentials file not found: $CREDENTIAL_FILE"
  exit 1
fi

# 💾 Write config.yml
log "Saving tunnel configuration..."
cat > "$CONFIG_DIR/config.yml" <<EOF
tunnel: $TUNNEL_ID
credentials-file: $CREDENTIAL_FILE

ingress:
  - hostname: $DOMAIN
    service: $LOCAL_URL
  - service: http_status:404
EOF

success "Configuration saved to $CONFIG_DIR/config.yml"

# 🌍 Configure DNS record
log "Configuring DNS record for $DOMAIN..."

# Parse domain
DOMAIN_PARTS=(${DOMAIN//./ })
if [ ${#DOMAIN_PARTS[@]} -ge 2 ]; then
    ROOT_DOMAIN="${DOMAIN_PARTS[-2]}.${DOMAIN_PARTS[-1]}"
    SUBDOMAIN="${DOMAIN%.$ROOT_DOMAIN}"
    
    log "Root domain: $ROOT_DOMAIN"
    log "Subdomain: $SUBDOMAIN"
fi

TUNNEL_TARGET="$TUNNEL_ID.cfargotunnel.com"

# Configure DNS based on authentication method
if [ "$USE_API" = true ]; then
    # Method: Use Cloudflare API directly
    log "Configuring DNS via Cloudflare API..."
    
    if [ -n "$CF_API_TOKEN" ]; then
            log "Fetching Zone ID for $ROOT_DOMAIN..."
            
            ZONE_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$ROOT_DOMAIN" \
                -H "Authorization: Bearer $CF_API_TOKEN" \
                -H "Content-Type: application/json")
            
            ZONE_ID=$(echo "$ZONE_RESPONSE" | jq -r '.result[0].id // empty')
            
            if [ -z "$ZONE_ID" ]; then
                warning "Could not find zone for $ROOT_DOMAIN"
            else
                log "Zone ID: $ZONE_ID"
                
                # Check if record exists
                log "Checking existing DNS records..."
                RECORDS_RESPONSE=$(curl -s -X GET \
                    "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$DOMAIN&type=CNAME" \
                    -H "Authorization: Bearer $CF_API_TOKEN" \
                    -H "Content-Type: application/json")
                
                RECORD_ID=$(echo "$RECORDS_RESPONSE" | jq -r '.result[0].id // empty')
                
                if [ -n "$RECORD_ID" ]; then
                    log "Updating existing DNS record..."
                    UPDATE_RESPONSE=$(curl -s -X PUT \
                        "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
                        -H "Authorization: Bearer $CF_API_TOKEN" \
                        -H "Content-Type: application/json" \
                        --data "{\"type\":\"CNAME\",\"name\":\"$DOMAIN\",\"content\":\"$TUNNEL_TARGET\",\"proxied\":true}")
                    
                    if echo "$UPDATE_RESPONSE" | jq -e '.success' >/dev/null 2>&1; then
                        success "DNS record updated via API"
                    else
                        warning "Failed to update DNS via API"
                    fi
                else
                    log "Creating new DNS record..."
                    CREATE_RESPONSE=$(curl -s -X POST \
                        "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
                        -H "Authorization: Bearer $CF_API_TOKEN" \
                        -H "Content-Type: application/json" \
                        --data "{\"type\":\"CNAME\",\"name\":\"$DOMAIN\",\"content\":\"$TUNNEL_TARGET\",\"proxied\":true}")
                    
                    if echo "$CREATE_RESPONSE" | jq -e '.success' >/dev/null 2>&1; then
                        success "DNS record created via API"
                    else
                        warning "Failed to create DNS via API"
                    fi
                fi
            fi
    else
        warning "No API token available for DNS configuration"
    fi
else
    # Method: Use cloudflared CLI (requires cert.pem)
    log "Attempting automatic DNS configuration via cloudflared..."
    DNS_OUTPUT=$("$CLOUDFLARED_BIN" tunnel route dns "$TUNNEL_NAME" "$DOMAIN" 2>&1)

    if echo "$DNS_OUTPUT" | grep -q -E '(created|already exists|Successfully)'; then
        success "DNS record configured for $DOMAIN"
    else
        warning "Could not automatically configure DNS via cloudflared"
        log "DNS output: $DNS_OUTPUT"
        echo ""
        echo "⚠️  Please configure DNS manually:"
        echo "   1. Go to Cloudflare Dashboard → DNS"
        echo "   2. Add/Update CNAME record:"
        echo "      Name: $SUBDOMAIN"
        echo "      Target: $TUNNEL_TARGET"
        echo "      Proxy: Enabled (orange cloud)"
        echo ""
        read -p "Press Enter when DNS is configured..."
    fi
fi

# ⚙️ Create systemd service
SERVICE_FILE="/etc/systemd/system/cloudflared-$TUNNEL_NAME.service"

log "Creating systemd service..."
cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Cloudflare Tunnel - $TUNNEL_NAME (n8n)
After=network.target

[Service]
Type=simple
User=root
ExecStart=$CLOUDFLARED_BIN tunnel --config $CONFIG_DIR/config.yml run $TUNNEL_NAME
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

# Reload and enable service
systemctl daemon-reload
systemctl enable "cloudflared-$TUNNEL_NAME.service" > /dev/null 2>&1
systemctl restart "cloudflared-$TUNNEL_NAME.service"

sleep 2

# Check service status
if systemctl is-active --quiet "cloudflared-$TUNNEL_NAME.service"; then
    success "Cloudflare Tunnel service is running"
else
    warning "Service may not be running properly"
    echo "Check status with: systemctl status cloudflared-$TUNNEL_NAME.service"
fi

# ✅ Summary
echo ""
echo "=========================================="
echo "  🎉 Cloudflare Tunnel Setup Complete!"
echo "=========================================="
echo ""
echo "Tunnel Name:    $TUNNEL_NAME"
echo "Tunnel ID:      $TUNNEL_ID"
echo "Domain:         https://$DOMAIN"
echo "Local Service:  $LOCAL_URL"
echo "Config File:    $CONFIG_DIR/config.yml"
echo "Service:        cloudflared-$TUNNEL_NAME.service"
echo ""
echo "Useful commands:"
echo "  Status:  systemctl status cloudflared-$TUNNEL_NAME.service"
echo "  Logs:    journalctl -u cloudflared-$TUNNEL_NAME.service -f"
echo "  Restart: systemctl restart cloudflared-$TUNNEL_NAME.service"
echo "  Stop:    systemctl stop cloudflared-$TUNNEL_NAME.service"
echo ""
echo "Your n8n instance should now be accessible at:"
echo "  https://$DOMAIN"
echo ""
echo "=========================================="
