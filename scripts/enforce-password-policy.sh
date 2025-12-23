#!/bin/bash

################################################################################
# Script: enforce-password-policy.sh
# Purpose: Enforce password complexity requirements for macOS security baseline
# Description: Sets password policy via pwpolicy command
# Based on: SEC-Password profile (com.apple.mobiledevice.passwordpolicy)
# Author: Attuned IT
# Date: December 23, 2025
################################################################################

# Password policy requirements (from SEC-Password profile)
MIN_LENGTH=12
REQUIRE_ALPHANUMERIC=1
MIN_COMPLEX_CHARS=1
PIN_HISTORY=5

# Logging function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
    /usr/bin/logger -t "attuned-password" "$1"
}

log_message "======== Password Policy Enforcement Script Started ========"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    log_message "ERROR: This script must be run as root"
    exit 1
fi

# Get current logged-in user (not root)
current_user=$(stat -f%Su /dev/console)
log_message "Current user: $current_user"

# Check if user is valid
if [[ "$current_user" == "root" ]] || [[ "$current_user" == "_mbsetupuser" ]] || [[ -z "$current_user" ]]; then
    log_message "No valid user logged in. Skipping password policy enforcement."
    exit 0
fi

# Set global password policy
log_message "Setting global password policy requirements..."
log_message "- Minimum length: $MIN_LENGTH characters"
log_message "- Require alphanumeric: YES"
log_message "- Minimum complex characters: $MIN_COMPLEX_CHARS"
log_message "- Password history: $PIN_HISTORY"

# Apply password policy using pwpolicy
# Note: pwpolicy applies to local accounts

# Set minimum length
log_message "Setting minimum password length to $MIN_LENGTH..."
pwpolicy -setglobalpolicy "minChars=$MIN_LENGTH"

if [[ $? -eq 0 ]]; then
    log_message "SUCCESS: Minimum length set to $MIN_LENGTH"
else
    log_message "WARNING: Failed to set minimum length"
fi

# Require at least one letter
log_message "Requiring alphabetic characters..."
pwpolicy -setglobalpolicy "requiresAlpha=1"

if [[ $? -eq 0 ]]; then
    log_message "SUCCESS: Alphabetic requirement enabled"
else
    log_message "WARNING: Failed to set alphabetic requirement"
fi

# Require at least one number
log_message "Requiring numeric characters..."
pwpolicy -setglobalpolicy "requiresNumeric=1"

if [[ $? -eq 0 ]]; then
    log_message "SUCCESS: Numeric requirement enabled"
else
    log_message "WARNING: Failed to set numeric requirement"
fi

# Set password history
log_message "Setting password history to $PIN_HISTORY..."
pwpolicy -setglobalpolicy "usingHistory=$PIN_HISTORY"

if [[ $? -eq 0 ]]; then
    log_message "SUCCESS: Password history set to $PIN_HISTORY"
else
    log_message "WARNING: Failed to set password history"
fi

# Set minimum number of complex characters
log_message "Setting minimum complex characters to $MIN_COMPLEX_CHARS..."
pwpolicy -setglobalpolicy "minComplexChars=$MIN_COMPLEX_CHARS"

if [[ $? -eq 0 ]]; then
    log_message "SUCCESS: Minimum complex characters set to $MIN_COMPLEX_CHARS"
else
    log_message "WARNING: Failed to set minimum complex characters"
fi

# Verify current policy
log_message "Verifying password policy settings..."
current_policy=$(pwpolicy -getglobalpolicy 2>&1)

if [[ $? -eq 0 ]]; then
    log_message "Current global password policy:"
    log_message "$current_policy"
else
    log_message "WARNING: Could not retrieve current policy"
fi

log_message "======== Password Policy Enforcement Script Completed ========"
exit 0
