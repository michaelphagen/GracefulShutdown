#!/bin/bash

# If pmset doesn't have a shutdown time, exit
if [[ $(pmset -g sched | grep "shutdown") == "" ]]; then
  echo "pmset doesn't have a shutdown time, exiting"
  exit
fi

hour=$(pmset -g sched | grep "shutdown" | sed -e 's/  shutdown at //' -e 's/ every day//' -e 's/\:.*$//')
minute=$(pmset -g sched | grep "shutdown" | sed -e 's/  shutdown at //' -e 's/ every day//' -e 's/.*://' -e 's/[^0-9]*//g')
timeofday=$(pmset -g sched | grep "shutdown" | sed -e 's/  shutdown at //' -e 's/ every day//' -e 's/.*://' -e 's/[0-9]*//g')

# if time of day is PM, add 12 to hour
if [ "$timeofday" == "PM" ]; then
  hour=$((hour+12))
fi

#convert hour and minute from string to int
hour=$((10#$hour))
minute=$((10#$minute))

# Run the script 5 minutes before time of shutdown
if [ "$minute" -lt 5 ]; then
  minute=$(($minute+60-5))
  hour=$(($hour-1))
else
  minute=$(($minute-5))
fi

if [ "$hour" -lt 0 ]; then
  hour=$(($hour+24))
fi

time="$minute $hour * * *"
#time="00 15 * * *"
command="$time \"/Library/REMU/Graceful Shutdown/ShutdownUtility.bash\""
echo "command will be: $command"

tab=$(crontab -l)
# if ShutdownUtility.bash is already in crontab, remove it
if [[ $tab == *ShutdownUtility.bash* ]]; then
  echo "tab contains ShutdownUtility.bash, removing it"
  tab=$(echo "$tab" | grep -v ShutdownUtility.bash)
fi

# If crontab already had commands, add newline
if [[ $tab != "" ]]; then
  echo "tab is not empty, adding newline"
  tab=$(printf "$tab\n$command")
else
  echo "tab is empty, not adding newline"
  tab=$command
fi

# Echo command into crontab
echo "$tab" | crontab -