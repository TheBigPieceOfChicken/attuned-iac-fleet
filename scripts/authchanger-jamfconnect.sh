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
