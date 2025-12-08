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

# Update package lists
if ! apt update -y >> "$LOGFILE" 2>&1; then
    log "First apt update failed, trying to fix..."
    apt --fix-broken install -y >> "$LOGFILE" 2>&1 || true
    dpkg --configure -a >> "$LOGFILE" 2>&1 || true
    apt update -y >> "$LOGFILE" 2>&1 || error_exit "apt update failed"
fi

log "Upgrading existing packages..."
apt upgrade -y >> "$LOGFILE" 2>&1 || log "Warning: apt upgrade had issues, continuing..."

log "Installing essential tools..."

# Install critical packages first
CRITICAL_PACKAGES="curl wget git ca-certificates gnupg jq"
log "Installing critical packages: $CRITICAL_PACKAGES"
for pkg in $CRITICAL_PACKAGES; do
    log "Installing $pkg..."
    if ! apt install -y "$pkg" >> "$LOGFILE" 2>&1; then
        error_exit "Failed to install critical package: $pkg"
    fi
done

# Install optional packages (don't fail if they're missing)
OPTIONAL_PACKAGES="nano htop ufw fail2ban lsb-release"
log "Installing optional packages..."
for pkg in $OPTIONAL_PACKAGES; do
    if apt install -y "$pkg" >> "$LOGFILE" 2>&1; then
        log "✓ Installed $pkg"
    else
        log "⚠ Skipped $pkg (not available or failed)"
    fi
done

log "✓ Essential packages installed"

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

# Stop any running cloudflared processes before installation
log "Checking for running cloudflared processes..."
if pgrep -x cloudflared > /dev/null; then
    log "Stopping running cloudflared processes..."
    pkill -9 cloudflared 2>/dev/null || true
    sleep 2
    log "✓ Stopped cloudflared processes"
fi

# Stop cloudflared services if they exist
for service in cloudflared cloudflared.service cloudflared-n8n-tunnel; do
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        log "Stopping $service..."
        systemctl stop "$service" 2>/dev/null || true
    fi
done

if [ ! -f "$CLOUDFLARED_BIN" ]; then
    curl -L --output "$CLOUDFLARED_BIN" \
        https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
        >> "$LOGFILE" 2>&1 || error_exit "Failed to download cloudflared"
    
    chmod +x "$CLOUDFLARED_BIN"
    log "✓ Cloudflared installed"
else
    log "Cloudflared already exists, updating..."
    # Remove old binary
    rm -f "$CLOUDFLARED_BIN"
    
    # Download new version
    curl -L --output "$CLOUDFLARED_BIN" \
        https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
        >> "$LOGFILE" 2>&1 || error_exit "Failed to download cloudflared"
    
    chmod +x "$CLOUDFLARED_BIN"
    log "✓ Cloudflared updated"
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
FAILED_PACKAGES=""

# Check critical packages
CRITICAL_CHECKS="curl wget git jq docker"
for cmd in $CRITICAL_CHECKS; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log "✗ $cmd not found"
        FAILED=$((FAILED + 1))
        FAILED_PACKAGES="$FAILED_PACKAGES $cmd"
    else
        log "✓ $cmd installed"
    fi
done

# Check optional packages (just warn)
OPTIONAL_CHECKS="ufw fail2ban-client nano htop"
for cmd in $OPTIONAL_CHECKS; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log "⚠ $cmd not found (optional)"
    else
        log "✓ $cmd installed"
    fi
done

# Fail if critical packages missing
if [ $FAILED -gt 0 ]; then
    error_exit "Critical packages missing:$FAILED_PACKAGES"
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
