#!/bin/bash
#
# Show Cloudflare Tunnel Information
#

echo "=========================================="
echo "  Cloudflare Tunnel Information"
echo "=========================================="
echo ""

# Check if cloudflared is installed
if ! command -v cloudflared >/dev/null 2>&1; then
    echo "❌ cloudflared not installed"
    exit 1
fi

# Check authentication
if [ ! -f "/root/.cloudflared/cert.pem" ]; then
    echo "❌ Not authenticated with Cloudflare"
    echo ""
    echo "Run: cloudflared login"
    exit 1
fi

echo "✅ Authenticated with Cloudflare"
echo ""

# List all tunnels
echo "📋 Your Tunnels:"
echo "----------------------------------------"
cloudflared tunnel list
echo ""

# Show tunnel details
echo "📝 To get tunnel ID:"
echo "   cloudflared tunnel list | grep <tunnel-name> | awk '{print \$1}'"
echo ""

# Check if config exists
if [ -f "/root/.cloudflared/config.yml" ]; then
    echo "📄 Current Configuration:"
    echo "----------------------------------------"
    cat /root/.cloudflared/config.yml
    echo ""
    
    TUNNEL_ID=$(grep "^tunnel:" /root/.cloudflared/config.yml | awk '{print $2}')
    if [ -n "$TUNNEL_ID" ]; then
        echo "🔑 Tunnel ID: $TUNNEL_ID"
        echo "🌐 DNS Target: $TUNNEL_ID.cfargotunnel.com"
        echo ""
    fi
fi

# Show services
echo "🔧 Tunnel Services:"
echo "----------------------------------------"
systemctl list-units --all "cloudflared*" --no-pager
echo ""

echo "=========================================="
echo "  DNS Configuration"
echo "=========================================="
echo ""
echo "If DNS record exists, update it with:"
echo "  Type: CNAME"
echo "  Target: <TUNNEL_ID>.cfargotunnel.com"
echo "  Proxy: ON (orange cloud)"
echo ""
echo "Or use Cloudflare API to update DNS automatically"
echo "=========================================="
