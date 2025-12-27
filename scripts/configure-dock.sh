#!/bin/bash
LoggedInUser=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
LoggedInUserHome="/Users/$LoggedInUser"

if [ -e /usr/local/bin/dockutil ]; then
    /usr/local/bin/dockutil --remove all --no-restart "$LoggedInUserHome"
    /usr/local/bin/dockutil --add '/Applications/Google Chrome.app' --no-restart "$LoggedInUserHome"
    /usr/local/bin/dockutil --add '/Applications/Slack.app' --no-restart "$LoggedInUserHome"
    /usr/local/bin/dockutil --add '/Applications/zoom.us.app' --no-restart "$LoggedInUserHome"
    # Add other apps as needed
    /usr/local/bin/dockutil --add '/Applications' --view grid --display folder --no-restart "$LoggedInUserHome"
    /usr/local/bin/dockutil --add '~/Downloads' --view fan --display stack --no-restart "$LoggedInUserHome"
    
    # Marker file for tracking
    touch "$LoggedInUserHome/Library/Preferences/com.attuned.docksetup.plist"
fi

killall -KILL Dock
exit 0
