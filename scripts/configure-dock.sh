#!/bin/bash

# Wait for dock to be available
sleep 5

# Get current logged in user
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )

if [ "$currentUser" = "loginwindow" ] || [ -z "$currentUser" ]; then
    echo "No user logged in, exiting"
    exit 0
fi

# Path to dockutil
DOCKUTIL="/usr/local/bin/dockutil"

# Remove unwanted default apps
$DOCKUTIL --remove 'Maps' --no-restart "$currentUser"
$DOCKUTIL --remove 'Pages' --no-restart "$currentUser"
$DOCKUTIL --remove 'Numbers' --no-restart "$currentUser"
$DOCKUTIL --remove 'Keynote' --no-restart "$currentUser"
$DOCKUTIL --remove 'News' --no-restart "$currentUser"
$DOCKUTIL --remove 'Stocks' --no-restart "$currentUser"
$DOCKUTIL --remove 'TV' --no-restart "$currentUser"
$DOCKUTIL --remove 'Music' --no-restart "$currentUser"
$DOCKUTIL --remove 'Podcasts' --no-restart "$currentUser"
$DOCKUTIL --remove 'Freeform' --no-restart "$currentUser"

# Add apps you want
$DOCKUTIL --add '/Applications/Google Chrome.app' --position 2 --no-restart "$currentUser"
$DOCKUTIL --add '/Applications/Self Service+.app' --position end --no-restart "$currentUser"
$DOCKUTIL --add '/Applications/Slack.app' --position 3 --no-restart "$currentUser"
$DOCKUTIL --add '/Applications/Zoom.app' --position 4 --no-restart "$currentUser"
$DOCKUTIL --add '/Applications/Google Drive.app' --position 5 --no-restart "$currentUser"
$DOCKUTIL --add '/Applications/Keeper Password Manager.app' --position 6 --no-restart "$currentUser"

# Restart dock to apply changes
killall Dock

echo "Dock configured successfully for $currentUser"
exit 0
