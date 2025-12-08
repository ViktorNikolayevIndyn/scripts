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
# Check for API Token
# ============================================================================

if [ -z "$CF_API_TOKEN" ]; then
    echo ""
    log "Cloudflare API Token required"
    echo ""
    read -p "Enter Cloudflare API Token: " CF_API_TOKEN
    
    if [ -z "$CF_API_TOKEN" ]; then
        error "API Token is required"
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
