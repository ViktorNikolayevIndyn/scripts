#!/bin/bash
#
# n8n Setup Downloader
# Downloads all required files from GitHub repository
#

set -e

# Configuration
REPO_OWNER="YOUR-USERNAME"
REPO_NAME="YOUR-REPO"
BRANCH="main"
BASE_PATH="scripts_git/cloudflare_scripts/n8n/n8n_install_debian"
BASE_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/${BASE_PATH}"

# Files to download
FILES=(
    "setup.sh"
    "install-packages.sh"
    "generate-config.sh"
    "setup-cloudflare-tunnel.sh"
    "docker-compose.yml"
    ".env.example"
    "README.md"
)

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo "=========================================="
echo "  n8n Setup Files Downloader"
echo "=========================================="
echo ""

# Create directory
TARGET_DIR="n8n_install_debian"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

echo -e "${CYAN}Downloading files to: $(pwd)${NC}"
echo ""

# Download files
FAILED=0
for file in "${FILES[@]}"; do
    echo -n "Downloading $file... "
    if wget -q "$BASE_URL/$file" -O "$file" 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo "✗ Failed"
        FAILED=$((FAILED + 1))
    fi
done

echo ""

if [ $FAILED -eq 0 ]; then
    # Make scripts executable
    chmod +x *.sh
    
    echo -e "${GREEN}✅ All files downloaded successfully!${NC}"
    echo ""
    echo "Files in $(pwd):"
    ls -lh
    echo ""
    echo "To start installation:"
    echo "  cd $(pwd)"
    echo "  sudo bash setup.sh"
else
    echo "⚠️  $FAILED file(s) failed to download"
    echo "Check your internet connection and repository URL"
    exit 1
fi
