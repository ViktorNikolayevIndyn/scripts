#!/bin/bash
#
# Check Cloudflare Tunnel Configuration
#

echo "=========================================="
echo "  Cloudflare Tunnel Diagnostics"
echo "=========================================="
echo ""

# Check authentication
echo "1. Cloudflare Authentication:"
if [ -f "/root/.cloudflared/cert.pem" ]; then
    echo "   ✓ cert.pem exists"
else
    echo "   ✗ cert.pem missing - run: cloudflared login"
fi
echo ""

# Check tunnels
echo "2. Existing Tunnels:"
/usr/local/bin/cloudflared tunnel list 2>/dev/null || echo "   No tunnels found or not authenticated"
echo ""

# Check config
echo "3. Tunnel Configuration:"
if [ -f "/root/.cloudflared/config.yml" ]; then
    echo "   ✓ config.yml exists"
    echo "   Content:"
    cat /root/.cloudflared/config.yml | sed 's/^/   /'
else
    echo "   ✗ config.yml missing"
fi
echo ""

# Check services
echo "4. Systemd Services:"
systemctl list-units --all --type=service | grep cloudflared | sed 's/^/   /'
echo ""

# Check old service
echo "5. Old cloudflared.service (from setup.sh):"
if [ -f "/etc/systemd/system/cloudflared.service" ]; then
    echo "   ✓ Old service exists - needs to be disabled"
    echo "   Status:"
    systemctl status cloudflared --no-pager 2>&1 | head -10 | sed 's/^/   /'
else
    echo "   ✗ Old service not found"
fi
echo ""

# Check DNS records via Cloudflare API
echo "6. Required DNS Configuration:"
echo ""
echo "   You need to create CNAME record in Cloudflare Dashboard:"
echo "   - Name: trade (or your subdomain)"
echo "   - Target: <TUNNEL_ID>.cfargotunnel.com"
echo "   - Proxy: ON (orange cloud)"
echo ""
echo "   Find your TUNNEL_ID from tunnel list above"
echo ""

echo "=========================================="
echo "  Recommended Actions:"
echo "=========================================="
echo ""
echo "1. Stop old tunnel service:"
echo "   systemctl stop cloudflared"
echo "   systemctl disable cloudflared"
echo ""
echo "2. Complete tunnel setup:"
echo "   cd /opt/n8n"
echo "   ./setup-cloudflare-tunnel.sh"
echo ""
echo "3. Or manually configure DNS in Cloudflare Dashboard"
echo ""
echo "=========================================="
