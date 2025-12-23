#!/bin/zsh
# Created by Kyle Ericson
# Version 3.0
# Jamf Connect Notify Start
# Note you will need to ensure Jamf Connect is set to run in Notify Mode like this:
# /usr/local/bin/authchanger -reset -JamfConnect -Notify
# Credits to this script which some items were used from https://raw.githubusercontent.com/jamf/DEPNotify-Starter/master/depNotify.sh
​
# Caffeinate Mac to keep awake
/usr/bin/caffeinate -d -i -m -u & caffeinatePID=$!
​
# Quit Key set to command + control + x
​
ORG_NAME="Attuned IT"
BANNER_IMAGE_PATH="/Library/Resources/logo.png"
NOTIFY_LOG="/var/tmp/depnotify.log"
POLICY_ARRAY=(
  "Setting up your Mac 10% Complete...,rose"
  "Setting up your Mac 20% Complete...,pro"
  "Setting up your Mac 30% Complete...,username"
  "Setting up your Mac 45% Complete...,chrome"
  "Setting up your Mac 50% Complete...,level"
  "Setting up your Mac 60% Complete...,drive"
  "Setting up your Mac 65% Complete...,keeper"
  "Setting up your Mac 70% Complete...,slack"
  "Setting up your Mac 75% Complete...,zoom"
  "Setting up your Mac 80% Complete...,support"
  "Setting up your Mac 90% Complete...,tools"
  "Setting up your Mac 95% Complete...,aftermath"
  "Setting up your Mac 99% Complete...,settings"
)
​
ARAY_LENGTH="${#POLICY_ARRAY[@]}"
for (( index = 1; index <= count; index++ )); do
  echo "${index} of ${count}: ${POLICY_ARRAY[index]}"
done
​
echo "STARTING RUN" >> "$NOTIFY_LOG"
# Define the number of increments for the progress bar
echo "Command: Image: $BANNER_IMAGE_PATH" >> "$NOTIFY_LOG"
echo "Command: MainTitle: Installing Apps and Settings." >> "$NOTIFY_LOG"
echo "Command: MainText: Thanks for choosing a Mac at $ORG_NAME! We want you to have a few applications and settings configured before you get started with your new Mac. This process should take 10 to 20 minutes to complete. \n \n If you need additional software or help, please visit the Self Service app in your Applications folder or on your Dock." >> "$NOTIFY_LOG"
echo "Command: DeterminateManual: $ARAY_LENGTH" >> "$NOTIFY_LOG"
​
# Loop to run policies
for POLICY in "${POLICY_ARRAY[@]}"; do
  echo "Status: $(echo "$POLICY" | cut -d ',' -f1)" >> "$NOTIFY_LOG"
  /usr/local/bin/jamf policy -event "$(echo "$POLICY" | cut -d ',' -f2)"
  echo "Command: DeterminateManualStep: ${POLICY_ARRAY[index]}" >> "$NOTIFY_LOG"
done
​
sleep 5
​
### Clean Up
sleep 3
echo "Command: Quit" >> "$NOTIFY_LOG"
sleep 1
rm -rf "$NOTIFY_LOG"
# Disable notify screen from loginwindow process and remove script
/usr/local/bin/authchanger -reset -JamfConnect
rm -rf /usr/local/bin/start-jcnotify.sh
​
# Kill caffeinate process
kill "$caffeinatePID"
​
exit 0
