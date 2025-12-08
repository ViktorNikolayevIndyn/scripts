#!/bin/bash
#
# Package Installation Script for n8n Server Setup
# Installs: System packages, Docker, Docker Compose, Cloudflared
#

set -e

LOGFILE="/var/log/server-setup.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"
}

error_exit() {
    log "ERROR: $1"
    exit 1
}

# ============================================================================
# 1. System Update & Basic Packages
# ============================================================================
log "Installing basic system packages..."
apt update -y >> "$LOGFILE" 2>&1 || error_exit "apt update failed"
apt upgrade -y >> "$LOGFILE" 2>&1 || error_exit "apt upgrade failed"

log "Installing essential tools..."
apt install -y \
    curl \
    wget \
    git \
    nano \
    htop \
    ufw \
    fail2ban \
    ca-certificates \
    gnupg \
    software-properties-common \
    apt-transport-https \
    lsb-release \
    jq \
    >> "$LOGFILE" 2>&1 || error_exit "Failed to install basic packages"

log "✓ Basic packages installed"

# ============================================================================
# 2. Docker & Docker Compose
# ============================================================================
log "Installing Docker..."

# Add Docker's official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker packages
apt update -y >> "$LOGFILE" 2>&1
apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
    >> "$LOGFILE" 2>&1 || error_exit "Docker installation failed"

# Enable Docker service
systemctl enable docker >> "$LOGFILE" 2>&1
systemctl start docker >> "$LOGFILE" 2>&1

# Test Docker
if docker run --rm hello-world >> "$LOGFILE" 2>&1; then
    log "✓ Docker installed successfully"
else
    error_exit "Docker test failed"
fi

# Verify Docker Compose
if ! docker compose version >> "$LOGFILE" 2>&1; then
    error_exit "Docker Compose not working"
fi

# ============================================================================
# 3. Cloudflared (Cloudflare Tunnel)
# ============================================================================
log "Installing Cloudflared..."

CLOUDFLARED_BIN="/usr/local/bin/cloudflared"

if [ ! -f "$CLOUDFLARED_BIN" ]; then
    curl -L --output "$CLOUDFLARED_BIN" \
        https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
        >> "$LOGFILE" 2>&1 || error_exit "Failed to download cloudflared"
    
    chmod +x "$CLOUDFLARED_BIN"
else
    log "✓ Cloudflared already installed"
fi

# Verify cloudflared
if ! "$CLOUDFLARED_BIN" version >> "$LOGFILE" 2>&1; then
    error_exit "Cloudflared not working"
fi

CLOUDFLARED_VERSION=$("$CLOUDFLARED_BIN" version 2>/dev/null)
log "✓ Cloudflared installed: $CLOUDFLARED_VERSION"

# ============================================================================
# Verification
# ============================================================================
log "Verifying installations..."

FAILED=0

# Check curl
if ! command -v curl >/dev/null 2>&1; then
    error_exit "curl not installed"
fi

# Check wget
if ! command -v wget >/dev/null 2>&1; then
    error_exit "wget not installed"
fi

# Check git
if ! command -v git >/dev/null 2>&1; then
    error_exit "git not installed"
fi

# Check jq
if ! command -v jq >/dev/null 2>&1; then
    error_exit "jq not installed"
fi

# Check ufw
if ! command -v ufw >/dev/null 2>&1; then
    error_exit "ufw not installed"
fi

# Check fail2ban
if ! command -v fail2ban-client >/dev/null 2>&1; then
    error_exit "fail2ban not installed"
fi

# Check Docker
if ! command -v docker >/dev/null 2>&1; then
    error_exit "docker not installed"
fi

# Check Docker service
if ! systemctl is-active --quiet docker; then
    error_exit "Docker service not running"
fi

# Check Cloudflared
if [ ! -x "$CLOUDFLARED_BIN" ]; then
    error_exit "Cloudflared not executable"
fi

log "✓ All packages verified successfully"

# ============================================================================
# Summary
# ============================================================================
echo ""
echo "=========================================="
echo "  ✅ Package Installation Complete"
echo "=========================================="
echo ""
echo "Installed and verified:"
echo "  ✓ System tools: curl, wget, git, nano, htop, jq"
echo "  ✓ Security: ufw, fail2ban"
echo "  ✓ Docker: $(docker --version 2>/dev/null)"
echo "  ✓ Docker Compose: $(docker compose version 2>/dev/null)"
echo "  ✓ Cloudflared: $CLOUDFLARED_VERSION"
echo ""
echo "All packages verified and ready for n8n installation"
echo "Log file: $LOGFILE"
echo "=========================================="
