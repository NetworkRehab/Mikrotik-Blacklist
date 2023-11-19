#!/bin/bash

# Get the current date and time
datetime=$(date)

# Download the blacklist
if wget -q https://iplists.firehol.org/files/firehol_level1.netset -O firehol_level1.netset; then
    echo "Blacklist downloaded successfully."
else
    echo "Failed to download the blacklist. Exiting."
    exit 1
fi

# Create the MikroTik RouterOS script
echo "# Updated: $datetime" > mikrotik-blacklist.rsc
echo "/ip firewall address-list" >> mikrotik-blacklist.rsc

# Process the blacklist
iplist=$(grep -E "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/(3[0-2]|[1-2][0-9]|[0-9]))$" firehol_level1.netset)

i=1
while read -r n; do 
  echo "add list=mikrotik-blacklist address=$n" >> mikrotik-blacklist.rsc 
  i=$((i+1))
done <<< "$iplist"

# Clean up the downloaded file
rm -f firehol_level1.netset

echo "Blacklist processing completed."
