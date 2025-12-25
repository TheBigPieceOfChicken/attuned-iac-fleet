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

# Wait for Jamf Connect Login profile to be installed (max 5 minutes)
echo "$(date): Waiting for Jamf Connect Login profile to be installed..." >> "$LOGFILE"
MAX_WAIT=300  # 5 minutes
WAIT_INTERVAL=10  # Check every 10 seconds
ELAPSED=0

while [ $ELAPSED -lt $MAX_WAIT ]; do
    # Check if the Jamf Connect Login profile is installed by looking for its payload
    if /usr/bin/profiles -P | /usr/bin/grep -q "com.jamf.connect.login"; then
        echo "$(date): Jamf Connect Login profile detected" >> "$LOGFILE"
        break
    fi
    
    echo "$(date): Profile not yet installed, waiting ${WAIT_INTERVAL}s..." >> "$LOGFILE"
    sleep $WAIT_INTERVAL
    ELAPSED=$((ELAPSED + WAIT_INTERVAL))
done

if [ $ELAPSED -ge $MAX_WAIT ]; then
    echo "$(date): TIMEOUT - Jamf Connect Login profile not installed after ${MAX_WAIT}s" >> "$LOGFILE"
    exit 1
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
