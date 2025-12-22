#!/usr/bin/env bash

###################################################################################
# Jamf Pro Configuration Profile List Script (DRY RUN) - bash version
#
# This script simply lists all configuration profiles from Jamf Pro
# without downloading anything. Works on macOS without Python.
#
# Usage:
#   export JAMF_CLIENT_ID="your-client-id"
#   export JAMF_CLIENT_SECRET="your-client-secret"
#   bash list-jamf-profiles.sh
#
###################################################################################

set -euo pipefail

# Configuration
JAMF_URL="${JAMF_URL:-https://attunednfr.jamfcloud.com}"

# Check required variables
if [[ -z "${JAMF_CLIENT_ID:-}" ]] || [[ -z "${JAMF_CLIENT_SECRET:-}" ]]; then
    echo "❌ Error: JAMF_CLIENT_ID and JAMF_CLIENT_SECRET environment variables required"
    exit 1
fi

echo "======================================================================="
echo "JAMF PRO CONFIGURATION PROFILE INVENTORY - DRY RUN"
echo "======================================================================="
echo ""
echo "Jamf URL: $JAMF_URL"
echo "This script will list all profiles without making any changes."
echo ""

# Get authentication token
echo "[1/2] Authenticating with Jamf Pro API..."
TOKEN_RESPONSE=$(curl -s -X POST \
    -H "Accept: application/json" \
    -u "${JAMF_CLIENT_ID}:${JAMF_CLIENT_SECRET}" \
    "${JAMF_URL}/api/v1/auth/token" 2>&1)

if [[ $? -ne 0 ]]; then
    echo "      ❌ Authentication failed"
    exit 1
fi

TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [[ -z "$TOKEN" ]]; then
    echo "      ❌ Failed to extract token"
    echo "      Response: $TOKEN_RESPONSE"
    exit 1
fi

echo "      ✅ Authentication successful"
echo ""

# Fetch profiles list
echo "[2/2] Fetching configuration profiles list..."
PROFILES_XML=$(curl -s -X GET \
    -H "Authorization: Bearer $TOKEN" \
    -H "Accept: application/xml" \
    "${JAMF_URL}/JSSResource/osxconfigurationprofiles" 2>&1)

if [[ $? -ne 0 ]]; then
    echo "      ❌ Failed to fetch profiles"
    exit 1
fi

# Count profiles using grep
PROFILE_COUNT=$(echo "$PROFILES_XML" | grep -c "<os_x_configuration_profile>" || echo "0")

echo "      ✅ Found $PROFILE_COUNT configuration profiles"
echo ""

echo "======================================================================="
echo "PROFILE LIST"
echo "======================================================================="
echo ""

# Parse XML and display profiles (macOS has xpath built-in, but xmllint is safer)
if command -v xmllint &> /dev/null; then
    # Use xmllint if available
    echo "$PROFILES_XML" | xmllint --format - 2>/dev/null | \
        grep -E "<id>|<name>" | \
        sed 'N;s/\n/ /' | \
        sed 's/.*<id>\([^<]*\)<\/id>.*<name>\([^<]*\)<\/name>.*/[ID: \1]  \2/' | \
        sort -t: -k2 || echo "$PROFILES_XML"
else
    # Fallback: simple grep parsing
    echo "$PROFILES_XML" | grep -A1 "<id>" | grep -v "^--$" | \
        paste - - | \
        sed 's/.*<id>\([^<]*\)<\/id>.*<name>\([^<]*\)<\/name>.*/[ID: \1]  \2/' | \
        sort
fi

echo ""
echo "======================================================================="
echo "SUMMARY"
echo "======================================================================="
echo "Total profiles found: $PROFILE_COUNT"
echo ""
echo "======================================================================="
echo "NEXT STEPS"
echo "======================================================================="
echo "1. Review the profile list above"
echo "2. Identify critical profiles to migrate first"
echo "3. Run export-jamf-profiles.py to begin bulk export (requires Python)"
echo "4. Or manually add profiles one by one to main.tf"
echo ""
