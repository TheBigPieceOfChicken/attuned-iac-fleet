#!/bin/bash

currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )

if [ "$currentUser" = "loginwindow" ] || [ -z "$currentUser" ]; then
    echo "No user logged in, exiting"
    exit 0
fi

if [ ! -e /usr/local/bin/dockutil ]; then
    echo "dockutil not installed, exiting"
    exit 0
fi

# Check if key apps are installed
if [ ! -d "/Applications/Google Chrome.app" ] || [ ! -d "/Applications/Slack.app" ]; then
    echo "Required apps not yet installed, exiting"
    exit 0
fi

DOCKUTIL="/usr/local/bin/dockutil"

$DOCKUTIL --remove all --no-restart "$currentUser"
$DOCKUTIL --add '/System/Applications/Launchpad.app' --position 1 --no-restart "$currentUser"
$DOCKUTIL --add '/Applications/Google Chrome.app' --position 2 --no-restart "$currentUser"
$DOCKUTIL --add '/Applications/Slack.app' --position 3 --no-restart "$currentUser"
$DOCKUTIL --add '/Applications/zoom.us.app' --position 4 --no-restart "$currentUser"
$DOCKUTIL --add '/Applications/Google Drive.app' --position 5 --no-restart "$currentUser"
$DOCKUTIL --add '/Applications/Keeper Password Manager.app' --position 6 --no-restart "$currentUser"
$DOCKUTIL --add '/System/Applications/System Settings.app' --position 7 --no-restart "$currentUser"

killall Dock
echo "Dock configured successfully for $currentUser"
exit 0
