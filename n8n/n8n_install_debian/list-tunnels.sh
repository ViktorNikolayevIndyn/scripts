#!/bin/bash

# ============================================================================
# List Cloudflare Tunnels via API
# ============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }
warning() { echo -e "${YELLOW}⚠${NC} $1"; }

# ============================================================================
# Check for saved credentials
# ============================================================================

CONFIG_FILE="/root/.cloudflare-api-token"

# Check environment variable
if [ -n "$CF_API_TOKEN" ]; then
    log "Using API Token from environment variable"
# Check saved token file
elif [ -f "$CONFIG_FILE" ]; then
    CF_API_TOKEN=$(cat "$CONFIG_FILE")
    log "Using saved API Token from $CONFIG_FILE"
else
    # Ask for token
    echo ""
    log "Cloudflare authentication required"
    echo ""
    echo "Choose authentication method:"
    echo "1. API Token (recommended)"
    echo "2. cert.pem file (legacy)"
    echo ""
    read -p "Select method [1/2]: " AUTH_METHOD
    AUTH_METHOD=${AUTH_METHOD:-1}
    
    if [ "$AUTH_METHOD" = "1" ]; then
        echo ""
        log "Get your API Token from:"
        echo "https://dash.cloudflare.com/profile/api-tokens"
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
            echo "$CF_API_TOKEN" > "$CONFIG_FILE"
            chmod 600 "$CONFIG_FILE"
            success "API Token saved to $CONFIG_FILE"
        fi
        
    elif [ "$AUTH_METHOD" = "2" ]; then
        # Use cert.pem method
        error "cert.pem method not supported in this script"
        echo "Use: cloudflared tunnel list"
        exit 1
    else
        error "Invalid selection"
        exit 1
    fi
fi

# ============================================================================
# Get Account ID
# ============================================================================

log "Fetching account information..."

ACCOUNTS_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json")

CF_ACCOUNT_ID=$(echo "$ACCOUNTS_RESPONSE" | jq -r '.result[0].id // empty')
ACCOUNT_NAME=$(echo "$ACCOUNTS_RESPONSE" | jq -r '.result[0].name // empty')

if [ -z "$CF_ACCOUNT_ID" ]; then
    error "Could not fetch account ID"
    echo "Response: $ACCOUNTS_RESPONSE"
    exit 1
fi

success "Account: $ACCOUNT_NAME"
log "Account ID: $CF_ACCOUNT_ID"

# ============================================================================
# List Tunnels
# ============================================================================

echo ""
log "Fetching tunnels..."

TUNNELS_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/cfd_tunnel" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json")

TUNNEL_COUNT=$(echo "$TUNNELS_RESPONSE" | jq '.result | length')

if [ "$TUNNEL_COUNT" -eq 0 ]; then
    warning "No tunnels found"
    exit 0
fi

echo ""
echo "=========================================="
echo "  Cloudflare Tunnels ($TUNNEL_COUNT)"
echo "=========================================="
echo ""

echo "$TUNNELS_RESPONSE" | jq -r '.result[] | 
    "Name:       \(.name)\n" +
    "ID:         \(.id)\n" +
    "Created:    \(.created_at)\n" +
    "Status:     \(if .connections == [] then "INACTIVE" else "ACTIVE" end)\n" +
    "Connections: \(.connections | length)\n" +
    "---"'

echo ""
success "Found $TUNNEL_COUNT tunnel(s)"

# ============================================================================
# Show service status
# ============================================================================

echo ""
log "Checking tunnel services..."
echo ""

for service in cloudflared-n8n-tunnel cloudflared cloudflared.service; do
    if systemctl list-units --full --all | grep -q "$service"; then
        STATUS=$(systemctl is-active "$service" 2>/dev/null || echo "inactive")
        if [ "$STATUS" = "active" ]; then
            success "$service: RUNNING"
        else
            warning "$service: $STATUS"
        fi
    fi
done

echo ""
