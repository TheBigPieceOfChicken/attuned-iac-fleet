#!/bin/bash
# Jamf Connect AuthChanger Script
# Activates Jamf Connect Login window by running authchanger
# Run at enrollment completion to enable OIDC authentication

# Log file for troubleshooting
LOGFILE="/var/log/jamfconnect-authchanger.log"

echo "$(date): Starting Jamf Connect authchanger activation" >> "$LOGFILE"

# Check if Jamf Connect is installed
if [ ! -f "/usr/local/bin/authchanger" ]; then
    echo "$(date): ERROR - authchanger not found at /usr/local/bin/authchanger" >> "$LOGFILE"
    exit 1
fi

# Wait for BOTH Jamf Connect profiles to be installed (max 5 minutes)
echo "$(date): Waiting for Jamf Connect profiles to be installed..." >> "$LOGFILE"
MAX_WAIT=300
WAIT_INTERVAL=10
ELAPSED=0

LOGIN_PROFILE="com.jamf.connect.login"
LICENSE_PROFILE="com.jamf.connect.license"

while [ $ELAPSED -lt $MAX_WAIT ]; do
    LOGIN_FOUND=false
    LICENSE_FOUND=false
    
    if /usr/bin/profiles -P 2>/dev/null | /usr/bin/grep -q "$LOGIN_PROFILE"; then
        LOGIN_FOUND=true
    fi
    
    if /usr/bin/profiles -P 2>/dev/null | /usr/bin/grep -q "$LICENSE_PROFILE"; then
        LICENSE_FOUND=true
    fi
    
    if [ "$LOGIN_FOUND" = true ] && [ "$LICENSE_FOUND" = true ]; then
        echo "$(date): Both Jamf Connect profiles detected" >> "$LOGFILE"
        break
    fi
    
    echo "$(date): Waiting... Login=$LOGIN_FOUND, License=$LICENSE_FOUND" >> "$LOGFILE"
    sleep $WAIT_INTERVAL
    ELAPSED=$((ELAPSED + WAIT_INTERVAL))
done

if [ $ELAPSED -ge $MAX_WAIT ]; then
    echo "$(date): TIMEOUT - Profiles not installed after ${MAX_WAIT}s" >> "$LOGFILE"
    echo "$(date): Proceeding anyway to avoid blocking enrollment" >> "$LOGFILE"
fi

# Run authchanger to activate Jamf Connect
echo "$(date): Running authchanger -reset -JamfConnect" >> "$LOGFILE"
/usr/local/bin/authchanger -reset -JamfConnect

AUTHCHANGER_RESULT=$?

if [ $AUTHCHANGER_RESULT -eq 0 ]; then
    echo "$(date): SUCCESS - Jamf Connect login window activated" >> "$LOGFILE"
    exit 0
else
    echo "$(date): ERROR - authchanger failed with exit code $AUTHCHANGER_RESULT" >> "$LOGFILE"
    exit 1
fi
