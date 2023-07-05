#!/bin/bash
# Run as Current User
##############################################################################################

# Close Commonly Open Apps
closeAllAppsBash() {
killall "Live"
killall "Pro Tools"
killall "Logic Pro X"
killall "Sibelius"
killall "Google Chrome"
}

closeAllAppsApplescript() {
read -r -d '' applescript <<EOF
tell application "System Events" to set the visible of every process to true

set white_list to {"Finder"}

try
    tell application "Finder"
        set process_list to the name of every process whose visible is true
    end tell
    repeat with i from 1 to (number of items in process_list)
        set this_process to item i of the process_list
        if this_process is not in white_list then
            tell application this_process
                quit
            end tell
        end if
    end repeat
end try
EOF
osascript -e "$applescript"
}

# Generates message prompt with Shutdown and Cancel buttons.
read -r -d '' applescript <<EOF
display alert "The Computer will shutdown in 5 minutes. \
To cancel this shutdown, select cancel." \
buttons {"Shutdown Now", "Cancel"} giving up after 300
EOF
    response=$(osascript -e "$applescript")

if [[ $response = "button returned:Cancel, gave up:false" ]]; then
    exit
else
    # Close commonly open apps and shutdown. This can be done with either bash or 
    # applescript, but applescript will display a prompt the first time
    #closeAllAppsBash
    closeAllAppsBash
    osascript -e 'tell application "Finder"' -e 'shut down' -e 'end tell'
fi