#!/bin/bash

################################################################################
# Script: enforce-gatekeeper.sh
# Purpose: Enforce Gatekeeper settings for macOS security baseline
# Description: Ensures Gatekeeper is enabled with "App Store and identified developers" policy
# Based on: SEC-Gatekeeper profile (com.apple.systempolicy.control)
# Author: Attuned IT
# Date: December 23, 2025
################################################################################

# Logging function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
    /usr/bin/logger -t "attuned-gatekeeper" "$1"
}

log_message "======== Gatekeeper Enforcement Script Started ========"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    log_message "ERROR: This script must be run as root"
    exit 1
fi

# Get current Gatekeeper status
log_message "Checking current Gatekeeper status..."
current_status=$(spctl --status 2>&1)
log_message "Current status: $current_status"

# Enable Gatekeeper assessment
log_message "Enabling Gatekeeper assessment..."
spctl --master-enable

if [[ $? -eq 0 ]]; then
    log_message "SUCCESS: Gatekeeper assessment enabled"
else
    log_message "ERROR: Failed to enable Gatekeeper assessment"
    exit 1
fi

# Set Gatekeeper to allow App Store and identified developers
# This is equivalent to: AllowIdentifiedDevelopers=true, EnableAssessment=true
log_message "Configuring Gatekeeper policy to 'App Store and identified developers'..."

# The spctl command with --master-enable sets it to "App Store and identified developers" by default
# Verify the setting
verify_status=$(spctl --status 2>&1)

if [[ "$verify_status" == "assessments enabled" ]]; then
    log_message "SUCCESS: Gatekeeper is properly configured"
    log_message "Policy: App Store and identified developers"
    
    # Additional verification - check global assessment policy
    global_status=$(spctl --status --label "Developer ID" 2>&1)
    log_message "Developer ID assessment: $global_status"
    
    exit 0
else
    log_message "WARNING: Gatekeeper status verification returned unexpected result: $verify_status"
    exit 1
fi

log_message "======== Gatekeeper Enforcement Script Completed ========"
