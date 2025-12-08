#!/bin/bash
#
# n8n One-Click Setup Script with Cloudflare Tunnel
# Debian 12/13 only
# 
# Usage: bash setup.sh
# Optional: export CLOUDFLARE_TUNNEL_TOKEN="your-token" before running
#

set -e  # Exit on error

# ============================================================================
# Configuration Variables
# ============================================================================
LOGFILE="/var/log/server-setup.log"
N8N_DIR="/opt/n8n"
N8N_PORT="80"
PERMIT_ROOT_LOGIN="prohibit-password"  # Options: no, prohibit-password, yes
N8N_USER="n8nuser"
FAIL2BAN_MAXRETRY="5"
FAIL2BAN_BANTIME="600"

# ============================================================================
# Helper Functions
# ============================================================================
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"
}

error_exit() {
    log "ERROR: $1"
    exit 1
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root (sudo bash setup.sh)"
        exit 1
    fi
}

check_debian() {
    if [[ ! -f /etc/debian_version ]]; then
        error_exit "This script is designed for Debian only."
    fi
    
    DEBIAN_VERSION=$(cat /etc/debian_version | cut -d. -f1)
    if [[ "$DEBIAN_VERSION" != "12" && "$DEBIAN_VERSION" != "13" ]]; then
        error_exit "This script requires Debian 12 or 13. Found version: $DEBIAN_VERSION"
    fi
    
    log "Detected Debian version: $DEBIAN_VERSION"
}

# ============================================================================
# Main Script
# ============================================================================
clear
echo "=========================================="
echo "  n8n Server Setup with Cloudflare Tunnel"
echo "=========================================="
echo ""

check_root
check_debian

# Start logging
log "=== Starting server setup ==="

# ============================================================================
# 1. Install Packages
# ============================================================================
log "Step 1: Installing required packages..."

INSTALL_SCRIPT="$(dirname "$0")/install-packages.sh"
if [[ -f "$INSTALL_SCRIPT" ]]; then
    bash "$INSTALL_SCRIPT" || error_exit "Package installation failed"
else
    error_exit "install-packages.sh not found"
fi

log "✓ All packages installed"

# ============================================================================
# 2. Firewall (UFW)
# ============================================================================
log "Step 2: Configuring UFW firewall..."

# Reset UFW to default
ufw --force reset >> "$LOGFILE" 2>&1

# Set defaults
ufw default deny incoming >> "$LOGFILE" 2>&1
ufw default allow outgoing >> "$LOGFILE" 2>&1

# Allow SSH, HTTP, HTTPS
ufw allow 22/tcp comment 'SSH' >> "$LOGFILE" 2>&1
ufw allow 80/tcp comment 'HTTP' >> "$LOGFILE" 2>&1
ufw allow 443/tcp comment 'HTTPS' >> "$LOGFILE" 2>&1

# Enable UFW
echo "y" | ufw enable >> "$LOGFILE" 2>&1

log "✓ UFW firewall configured and enabled"
ufw status | tee -a "$LOGFILE"

# ============================================================================
# 3. Fail2Ban
# ============================================================================
log "Step 3: Configuring Fail2Ban..."

# Create jail.local from jail.conf
if [[ ! -f /etc/fail2ban/jail.local ]]; then
    cat > /etc/fail2ban/jail.local <<EOF
[DEFAULT]
bantime = ${FAIL2BAN_BANTIME}
findtime = 600
maxretry = ${FAIL2BAN_MAXRETRY}
destemail = root@localhost
sendername = Fail2Ban
action = %(action_mw)s

[sshd]
enabled = true
port = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s
maxretry = ${FAIL2BAN_MAXRETRY}
EOF
    log "Created /etc/fail2ban/jail.local"
fi

# Enable and start fail2ban
systemctl enable fail2ban >> "$LOGFILE" 2>&1
systemctl restart fail2ban >> "$LOGFILE" 2>&1

sleep 2
log "✓ Fail2Ban configured and running"
fail2ban-client status sshd | tee -a "$LOGFILE"

# ============================================================================
# 4. User Management & SSH Hardening
# ============================================================================
log "Step 4: Setting up user and hardening SSH..."

# Create n8n user if not exists
if ! id -u "$N8N_USER" > /dev/null 2>&1; then
    useradd -m -s /bin/bash "$N8N_USER"
    usermod -aG sudo "$N8N_USER"
    log "Created user: $N8N_USER"
else
    log "User $N8N_USER already exists"
fi

# SSH Hardening
log "Configuring SSH security..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i "s/^#*PermitRootLogin.*/PermitRootLogin $PERMIT_ROOT_LOGIN/" /etc/ssh/sshd_config

systemctl restart sshd >> "$LOGFILE" 2>&1

log "✓ SSH hardened (PasswordAuthentication disabled, PubkeyAuthentication enabled)"

# ============================================================================
# 5. Docker Group Access
# ============================================================================
log "Step 5: Configuring Docker access for user..."

# Add user to docker group
usermod -aG docker "$N8N_USER"

log "✓ User $N8N_USER added to docker group"

# ============================================================================
# 6. n8n Configuration
# ============================================================================
log "Step 6: Generating n8n configuration..."

# Create n8n directory
mkdir -p "$N8N_DIR"
cd "$N8N_DIR"

# Generate config if not exists
if [[ ! -f "$N8N_DIR/.env" ]]; then
    # Try multiple locations for generate-config.sh
    CONFIG_SCRIPT=""
    
    # 1. Check if running from install.sh (exported variable)
    if [[ -n "$SETUP_SCRIPT_DIR" ]] && [[ -f "$SETUP_SCRIPT_DIR/generate-config.sh" ]]; then
        CONFIG_SCRIPT="$SETUP_SCRIPT_DIR/generate-config.sh"
    # 2. Check same directory as setup.sh
    elif [[ -f "$(dirname "$0")/generate-config.sh" ]]; then
        CONFIG_SCRIPT="$(dirname "$0")/generate-config.sh"
    # 3. Check current directory
    elif [[ -f "./generate-config.sh" ]]; then
        CONFIG_SCRIPT="./generate-config.sh"
    # 4. Check /tmp directory patterns
    elif compgen -G "/tmp/n8n_setup_*/generate-config.sh" > /dev/null; then
        CONFIG_SCRIPT=$(ls -t /tmp/n8n_setup_*/generate-config.sh 2>/dev/null | head -1)
    fi
    
    if [[ -n "$CONFIG_SCRIPT" ]] && [[ -f "$CONFIG_SCRIPT" ]]; then
        log "Using config generator: $CONFIG_SCRIPT"
        bash "$CONFIG_SCRIPT" || error_exit "Configuration generation failed"
    else
        log "⚠ generate-config.sh not found, creating basic configuration..."
        
        # Interactive fallback
        read -p "Enter n8n hostname (e.g., n8n.example.com): " N8N_HOSTNAME
        read -p "Enter Basic Auth username [admin]: " N8N_AUTH_USER
        N8N_AUTH_USER=${N8N_AUTH_USER:-admin}
        read -s -p "Enter Basic Auth password: " N8N_AUTH_PASS
        echo ""
        
        if [[ -z "$N8N_AUTH_PASS" ]]; then
            N8N_AUTH_PASS=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
            log "Generated password: $N8N_AUTH_PASS"
        fi
        
        # Create .env file
        cat > "$N8N_DIR/.env" <<EOF
# n8n Configuration
N8N_HOST=${N8N_HOSTNAME}
N8N_PORT=80
N8N_PROTOCOL=https
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=${N8N_AUTH_USER}
N8N_BASIC_AUTH_PASSWORD=${N8N_AUTH_PASS}

# Database Configuration
POSTGRES_USER=n8n
POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
POSTGRES_DB=n8n

# Timezone
GENERIC_TIMEZONE=Europe/Berlin
TZ=Europe/Berlin
EOF
        chmod 600 "$N8N_DIR/.env"
        log "✓ Configuration created at $N8N_DIR/.env"
    fi
else
    log "✓ Configuration file already exists"
fi

# Load configuration
source "$N8N_DIR/.env"
log "✓ Configuration loaded"

# Copy docker-compose.yml
cp "$(dirname "$0")/docker-compose.yml" "$N8N_DIR/docker-compose.yml" 2>/dev/null || \
cat > "$N8N_DIR/docker-compose.yml" <<'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    restart: unless-stopped
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
    volumes:
      - postgres-data:/var/lib/postgresql/data
    healthcheck:
      test: ['CMD-SHELL', 'pg_isready -h localhost -U ${POSTGRES_USER} -d ${POSTGRES_DB}']
      interval: 5s
      timeout: 5s
      retries: 10
    networks:
      - n8n-network

  n8n:
    image: n8nio/n8n:latest
    restart: unless-stopped
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=${POSTGRES_DB}
      - DB_POSTGRESDB_USER=${POSTGRES_USER}
      - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}
      - N8N_HOST=${N8N_HOST}
      - N8N_PORT=${N8N_PORT}
      - N8N_PROTOCOL=${N8N_PROTOCOL}
      - WEBHOOK_URL=https://${N8N_HOST}
      - N8N_BASIC_AUTH_ACTIVE=${N8N_BASIC_AUTH_ACTIVE}
      - N8N_BASIC_AUTH_USER=${N8N_BASIC_AUTH_USER}
      - N8N_BASIC_AUTH_PASSWORD=${N8N_BASIC_AUTH_PASSWORD}
      - GENERIC_TIMEZONE=${GENERIC_TIMEZONE}
      - TZ=${TZ}
    ports:
      - "127.0.0.1:${N8N_PORT}:5678"
    volumes:
      - n8n-data:/home/node/.n8n
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - n8n-network

volumes:
  n8n-data:
    driver: local
  postgres-data:
    driver: local

networks:
  n8n-network:
    driver: bridge
EOF

log "Created docker-compose.yml"

# Set permissions
chown -R "$N8N_USER":"$N8N_USER" "$N8N_DIR"

log "✓ n8n configuration complete"

# ============================================================================
# 7. Cloudflare Tunnel (cloudflared)
# ============================================================================
log "Step 7: Installing and configuring Cloudflare Tunnel..."

# Check for tunnel token
if [[ -z "$CLOUDFLARE_TUNNEL_TOKEN" ]]; then
    read -p "Enter Cloudflare Tunnel Token: " CLOUDFLARE_TUNNEL_TOKEN
fi

if [[ -z "$CLOUDFLARE_TUNNEL_TOKEN" ]]; then
    error_exit "Cloudflare Tunnel Token is required"
fi

# Install cloudflared
curl -L --output /usr/local/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x /usr/local/bin/cloudflared

# Create cloudflared systemd service
cat > /etc/systemd/system/cloudflared.service <<EOF
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/cloudflared tunnel --no-autoupdate run --token ${CLOUDFLARE_TUNNEL_TOKEN}
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

# Enable and start cloudflared
systemctl daemon-reload
systemctl enable cloudflared >> "$LOGFILE" 2>&1
systemctl start cloudflared >> "$LOGFILE" 2>&1

sleep 3
log "✓ Cloudflare Tunnel configured and running"

# ============================================================================
# 8. Start n8n Services
# ============================================================================
log "Step 8: Starting n8n Docker services..."

cd "$N8N_DIR"
docker compose up -d >> "$LOGFILE" 2>&1 || error_exit "Failed to start n8n containers"

sleep 5
log "✓ n8n containers started"

# ============================================================================
# 9. Create systemd service for n8n auto-start
# ============================================================================
log "Step 9: Creating systemd service for n8n auto-start..."

cat > /etc/systemd/system/n8n-docker.service <<EOF
[Unit]
Description=n8n Docker Compose Service
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=${N8N_DIR}
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable n8n-docker.service >> "$LOGFILE" 2>&1

log "✓ n8n auto-start service created"

# ============================================================================
# 10. Final Status & Summary
# ============================================================================
echo ""
echo "=========================================="
echo "  Setup Complete!"
echo "=========================================="
echo ""

log "=== Final System Status ==="

echo "UFW Firewall Status:"
ufw status | tee -a "$LOGFILE"
echo ""

echo "Fail2Ban Status:"
fail2ban-client status | tee -a "$LOGFILE"
echo ""

echo "Docker Containers:"
docker ps | tee -a "$LOGFILE"
echo ""

echo "Cloudflare Tunnel Status:"
systemctl status cloudflared --no-pager | tee -a "$LOGFILE"
echo ""

echo "=========================================="
echo "  Access Information"
echo "=========================================="
echo "n8n URL: https://${N8N_HOSTNAME}"
echo "Username: ${N8N_AUTH_USER}"
echo "Password: (as configured)"
echo ""
echo "Configuration directory: $N8N_DIR"
echo "Logs: $LOGFILE"
echo ""
echo "Useful commands:"
echo "  - Check n8n logs: cd $N8N_DIR && docker compose logs -f"
echo "  - Restart n8n: cd $N8N_DIR && docker compose restart"
echo "  - Stop n8n: cd $N8N_DIR && docker compose down"
echo "  - Cloudflare status: systemctl status cloudflared"
echo "=========================================="

log "=== Setup completed successfully ==="
