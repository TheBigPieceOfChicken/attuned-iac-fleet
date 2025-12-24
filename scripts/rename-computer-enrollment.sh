#!/bin/bash

################################################################################
# Jamf Pro Enrollment Script - Secure Computer Naming with Hex
# Generates random, memorable device names using dictionary words + hex suffix
# Format: ABC-defgh-xxxx (e.g., dog-chien-ba83)
#
# Naming Convention:
# - 3-letter word (uppercase)
# - 5-letter word (lowercase)  
# - 4-character hex (lowercase)
# Total: 3+1+5+1+4 = 14 chars (NetBIOS safe, memorable)
#
# Security Benefits:
# - No PII exposure (no usernames/emails/serial numbers)
# - 65,536 unique hex combinations per word pair
# - Pronounceable for phone support
# - Short enough for NetBIOS (15 char limit)
# - OPSEC-friendly for distributed/remote workforce
################################################################################

# Path to system dictionary
DICT_PATH="/usr/share/dict/words"

# Function to get random 3-letter word (uppercase)
get_3letter_word() {
    grep -E '^[A-Z]{3}$' "$DICT_PATH" 2>/dev/null | \
    shuf -n 1 || echo "DOG"  # Fallback
}

# Function to get random 5-letter word (lowercase)
get_5letter_word() {
    grep -E '^[a-z]{5}$' "$DICT_PATH" 2>/dev/null | \
    shuf -n 1 || echo "chien"  # Fallback
}

# Generate random 4-character hex (lowercase)
generate_hex() {
    openssl rand -hex 2 | tr '[:upper:]' '[:lower:]'
}

# Generate components
word1=$(get_3letter_word)
word2=$(get_5letter_word)
hexSuffix=$(generate_hex)

# Construct computer name
computerName="${word1}-${word2}-${hexSuffix}"

echo "Generated Computer Name: $computerName"
echo "  - 3-letter word: $word1"
echo "  - 5-letter word: $word2"
echo "  - Hex suffix: $hexSuffix"
echo "  - Total length: ${#computerName} characters"

# Validate length (should be exactly 14 chars: 3+1+5+1+4)
if [ ${#computerName} -ne 14 ]; then
    echo "WARNING: Name length is ${#computerName}, expected 14"
fi

# Set all three name types using scutil
/usr/sbin/scutil --set ComputerName "$computerName"
/usr/sbin/scutil --set LocalHostName "$computerName"
/usr/sbin/scutil --set HostName "$computerName"

# Update Jamf Pro inventory
/usr/local/bin/jamf setComputerName -name "$computerName"
/usr/local/bin/jamf recon

echo "✓ Computer successfully renamed to: $computerName"

exit 0
