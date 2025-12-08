#!/bin/bash

# ============================================================================
# Manage Cloudflare API Token
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

API_TOKEN_FILE="/root/.cloudflare-api-token"

# ============================================================================
# Menu
# ============================================================================

echo ""
echo "=========================================="
echo "  Cloudflare API Token Management"
echo "=========================================="
echo ""

if [ -f "$API_TOKEN_FILE" ]; then
    TOKEN=$(cat "$API_TOKEN_FILE")
    TOKEN_PREVIEW="${TOKEN:0:20}...${TOKEN: -10}"
    success "Saved token found: $TOKEN_PREVIEW"
    echo ""
    echo "Options:"
    echo "1. Test current token"
    echo "2. Update token"
    echo "3. Delete token"
    echo "4. Exit"
else
    warning "No saved token found"
    echo ""
    echo "Options:"
    echo "1. Save new token"
    echo "2. Exit"
fi

echo ""
read -p "Select option: " OPTION

case $OPTION in
    1)
        if [ -f "$API_TOKEN_FILE" ]; then
            # Test token
            log "Testing API Token..."
            TOKEN=$(cat "$API_TOKEN_FILE")
            
            # Get account info first
            ACCOUNTS_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts" \
                -H "Authorization: Bearer $TOKEN" \
                -H "Content-Type: application/json")
            
            ACCOUNT_ID=$(echo "$ACCOUNTS_RESPONSE" | jq -r '.result[0].id // empty')
            ACCOUNT_NAME=$(echo "$ACCOUNTS_RESPONSE" | jq -r '.result[0].name // empty')
            
            if [ -z "$ACCOUNT_ID" ]; then
                error "Could not fetch account information"
                echo "Response: $ACCOUNTS_RESPONSE" | jq '.'
                exit 1
            fi
            
            # Verify token using account-specific endpoint
            TEST_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/tokens/verify" \
                -H "Authorization: Bearer $TOKEN")
            
            TOKEN_STATUS=$(echo "$TEST_RESPONSE" | jq -r '.result.status // empty')
            
            if [ "$TOKEN_STATUS" = "active" ]; then
                success "✓ Token is valid and active"
                log "Account: $ACCOUNT_NAME"
                log "Account ID: $ACCOUNT_ID"
            else
                error "Token verification failed"
                echo "$TEST_RESPONSE" | jq '.'
            fi
        else
            # Save new token
            echo ""
            log "Get your API Token from:"
            echo "https://dash.cloudflare.com/profile/api-tokens"
            echo ""
            read -p "Enter Cloudflare API Token: " NEW_TOKEN
            
            if [ -z "$NEW_TOKEN" ]; then
                error "Token cannot be empty"
                exit 1
            fi
            
            # Test before saving
            log "Testing token..."
            ACCOUNTS_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts" \
                -H "Authorization: Bearer $NEW_TOKEN" \
                -H "Content-Type: application/json")
            
            ACCOUNT_ID=$(echo "$ACCOUNTS_RESPONSE" | jq -r '.result[0].id // empty')
            
            if [ -n "$ACCOUNT_ID" ]; then
                echo "$NEW_TOKEN" > "$API_TOKEN_FILE"
                chmod 600 "$API_TOKEN_FILE"
                success "Token saved to $API_TOKEN_FILE"
            else
                error "Token verification failed"
                echo "Response: $ACCOUNTS_RESPONSE" | jq '.'
                exit 1
            fi
        fi
        ;;
    
    2)
        if [ -f "$API_TOKEN_FILE" ]; then
            # Update token
            echo ""
            log "Get your API Token from:"
            echo "https://dash.cloudflare.com/profile/api-tokens"
            echo ""
            read -p "Enter new Cloudflare API Token: " NEW_TOKEN
            
            if [ -z "$NEW_TOKEN" ]; then
                error "Token cannot be empty"
                exit 1
            fi
            
            # Test before saving
            log "Testing token..."
            ACCOUNTS_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts" \
                -H "Authorization: Bearer $NEW_TOKEN" \
                -H "Content-Type: application/json")
            
            ACCOUNT_ID=$(echo "$ACCOUNTS_RESPONSE" | jq -r '.result[0].id // empty')
            
            if [ -n "$ACCOUNT_ID" ]; then
                echo "$NEW_TOKEN" > "$API_TOKEN_FILE"
                chmod 600 "$API_TOKEN_FILE"
                success "Token updated"
            else
                error "Token verification failed"
                echo "Response: $ACCOUNTS_RESPONSE" | jq '.'
                exit 1
            fi
        else
            # Exit
            log "Goodbye!"
            exit 0
        fi
        ;;
    
    3)
        if [ -f "$API_TOKEN_FILE" ]; then
            # Delete token
            read -p "Delete saved token? [y/N]: " CONFIRM
            if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
                rm -f "$API_TOKEN_FILE"
                success "Token deleted"
            else
                log "Cancelled"
            fi
        fi
        ;;
    
    4)
        log "Goodbye!"
        exit 0
        ;;
    
    *)
        error "Invalid option"
        exit 1
        ;;
esac

echo ""
