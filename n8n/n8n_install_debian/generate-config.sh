#!/bin/bash
#
# Configuration Generator for n8n Setup
# Creates .env file if it doesn't exist
#

set -e

# Use N8N_DIR from environment or default to /opt/n8n
N8N_DIR="${N8N_DIR:-/opt/n8n}"
CONFIG_DIR="$N8N_DIR"
ENV_FILE="$CONFIG_DIR/.env"
ENV_EXAMPLE="$(dirname "$0")/.env.example"

# Ensure directory exists
mkdir -p "$CONFIG_DIR"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log() {
    echo -e "${CYAN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $*"
}

success() {
    echo -e "${GREEN}✅${NC} $*"
}

warning() {
    echo -e "${YELLOW}⚠️${NC} $*"
}

generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-25
}

echo ""
echo "=========================================="
echo "  n8n Configuration Generator"
echo "=========================================="
echo ""

# Check if .env already exists
if [[ -f "$ENV_FILE" ]]; then
    warning ".env file already exists at: $ENV_FILE"
    read -p "Overwrite existing configuration? [y/N]: " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
        log "Keeping existing configuration"
        exit 0
    fi
    log "Backing up existing .env to .env.backup"
    cp "$ENV_FILE" "$ENV_FILE.backup"
fi

# Gather configuration
log "Please provide the following information:"
echo ""

# n8n Host
read -p "🌐 n8n domain (e.g., n8n.example.com): " N8N_HOST
while [[ -z "$N8N_HOST" ]]; do
    echo "Domain is required!"
    read -p "🌐 n8n domain: " N8N_HOST
done

# Basic Auth User
read -p "👤 Basic Auth username [admin]: " N8N_AUTH_USER
N8N_AUTH_USER=${N8N_AUTH_USER:-admin}

# Basic Auth Password
read -s -p "🔒 Basic Auth password (press Enter to generate): " N8N_AUTH_PASS
echo ""
if [[ -z "$N8N_AUTH_PASS" ]]; then
    N8N_AUTH_PASS=$(generate_password)
    log "Generated Basic Auth password: $N8N_AUTH_PASS"
fi

# Database User
read -p "🗄️  PostgreSQL username [n8n]: " POSTGRES_USER
POSTGRES_USER=${POSTGRES_USER:-n8n}

# Database Password
read -s -p "🔐 PostgreSQL password (press Enter to generate): " POSTGRES_PASS
echo ""
if [[ -z "$POSTGRES_PASS" ]]; then
    POSTGRES_PASS=$(generate_password)
    log "Generated PostgreSQL password: $POSTGRES_PASS"
fi

# Database Name
read -p "📊 PostgreSQL database name [n8n]: " POSTGRES_DB
POSTGRES_DB=${POSTGRES_DB:-n8n}

# Timezone
read -p "🌍 Timezone [Europe/Berlin]: " TIMEZONE
TIMEZONE=${TIMEZONE:-Europe/Berlin}

# Create .env file
log "Creating .env file..."

cat > "$ENV_FILE" <<EOF
# n8n Configuration
# Generated on $(date)

# n8n Host Settings
N8N_HOST=$N8N_HOST
N8N_PORT=80
N8N_PROTOCOL=https

# Basic Authentication
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=$N8N_AUTH_USER
N8N_BASIC_AUTH_PASSWORD=$N8N_AUTH_PASS

# Database Configuration
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$POSTGRES_PASS
POSTGRES_DB=$POSTGRES_DB

# Timezone Configuration
GENERIC_TIMEZONE=$TIMEZONE
TZ=$TIMEZONE
EOF

chmod 600 "$ENV_FILE"
success ".env file created at: $ENV_FILE"

# Display summary
echo ""
echo "=========================================="
echo "  Configuration Summary"
echo "=========================================="
echo ""
echo "n8n URL:        https://$N8N_HOST"
echo "n8n Port:       80"
echo "Auth User:      $N8N_AUTH_USER"
echo "Auth Password:  $N8N_AUTH_PASS"
echo ""
echo "Database User:  $POSTGRES_USER"
echo "Database Pass:  $POSTGRES_PASS"
echo "Database Name:  $POSTGRES_DB"
echo ""
echo "Timezone:       $TIMEZONE"
echo ""
echo "=========================================="
echo ""
warning "IMPORTANT: Save these credentials securely!"
echo ""
echo "Configuration file: $ENV_FILE"
echo ""
