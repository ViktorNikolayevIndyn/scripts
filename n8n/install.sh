#!/bin/bash
#
# n8n Quick Installer
# One-command setup for n8n with Cloudflare Tunnel on Debian 12/13
#
# Usage: bash -c "$(curl -fsSL https://raw.githubusercontent.com/ViktorNikolayevIndyn/scripts/main/n8n/install.sh)"
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log() {
    echo -e "${CYAN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $*"
}

error() {
    echo -e "${RED}❌ ERROR:${NC} $*" >&2
    exit 1
}

success() {
    echo -e "${GREEN}✅${NC} $*"
}

# Check root
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root (use sudo)"
fi

# Check Debian
if [[ ! -f /etc/debian_version ]]; then
    error "This script is designed for Debian only"
fi

DEBIAN_VERSION=$(cat /etc/debian_version | cut -d. -f1)
if [[ "$DEBIAN_VERSION" != "12" && "$DEBIAN_VERSION" != "13" ]]; then
    error "This script requires Debian 12 or 13. Found version: $DEBIAN_VERSION"
fi

# Configuration
REPO_URL="https://raw.githubusercontent.com/ViktorNikolayevIndyn/scripts/main/n8n/n8n_install_debian"
WORK_DIR="/tmp/n8n_setup_$$"
INSTALL_DIR="/opt/n8n"

echo ""
echo "=========================================="
echo "  n8n One-Click Installer"
echo "=========================================="
echo ""
log "Debian $DEBIAN_VERSION detected"
log "Creating temporary directory..."

# Create temp directory
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Download files
log "Downloading installation files..."

FILES=(
    "setup.sh"
    "install-packages.sh"
    "generate-config.sh"
    "setup-cloudflare-tunnel.sh"
    "docker-compose.yml"
    ".env.example"
)

FAILED=0
for file in "${FILES[@]}"; do
    if ! curl -fsSL "$REPO_URL/$file" -o "$file" 2>/dev/null; then
        error "Failed to download $file"
    fi
done

success "All files downloaded"

# Make scripts executable
chmod +x *.sh

# Run setup
log "Starting n8n setup..."
echo ""

bash setup.sh

# Cleanup
cd /
rm -rf "$WORK_DIR"

echo ""
echo "=========================================="
echo "  ✅ Installation Complete!"
echo "=========================================="
echo ""
echo "n8n is now running in Docker"
echo ""
echo "Next steps:"
echo "  1. Configure Cloudflare Tunnel:"
echo "     cd $INSTALL_DIR"
echo "     bash setup-cloudflare-tunnel.sh"
echo ""
echo "  2. Check n8n status:"
echo "     docker ps"
echo "     docker logs n8n"
echo ""
echo "  3. View logs:"
echo "     tail -f /var/log/server-setup.log"
echo ""
echo "=========================================="
