#!/bin/bash

################################################################################
# Jamf Pro Enrollment Script - Secure Computer Naming with Hex
# Generates random, memorable device names using dictionary words + hex suffix
# Format: ABC-defgh-xxxx (e.g., DOG-chien-ba83)
################################################################################

DICT_PATH="/usr/share/dict/words"

# Function to get random 3-letter word (converted to uppercase)
get_3letter_word() {
    word=$(grep -E '^[A-Za-z]{3}$' "$DICT_PATH" 2>/dev/null | shuf -n 1)
    if [ -n "$word" ]; then
        echo "$word" | tr '[:lower:]' '[:upper:]'
    else
        echo "MAC"
    fi
}

# Function to get random 5-letter word (converted to lowercase)
get_5letter_word() {
    word=$(grep -E '^[A-Za-z]{5}$' "$DICT_PATH" 2>/dev/null | shuf -n 1)
    if [ -n "$word" ]; then
        echo "$word" | tr '[:upper:]' '[:lower:]'
    else
        echo "apple"
    fi
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
