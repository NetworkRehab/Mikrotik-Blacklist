#!/bin/bash

# Configuration options
BLACKLIST_URL="https://iplists.firehol.org/files/firehol_level1.netset"
ADDRESS_LIST_NAME="mikrotik-blacklist"
OUTPUT_FILE="mikrotik-blacklist.rsc"

# Get the current date and time
datetime=$(date)

# Download the blacklist with retries and timeout
if wget -q --timeout=30 --tries=3 "$BLACKLIST_URL" -O firehol_level1.netset; then
    echo "Blacklist downloaded successfully."
else
    echo "Failed to download the blacklist. Exiting."
    exit 1
fi

# Create the MikroTik RouterOS script
{
    echo "# Updated: $datetime"
    echo "/ip firewall address-list"
} > "$OUTPUT_FILE"

# Process the blacklist
while read -r n; do
    echo "add list=$ADDRESS_LIST_NAME address=$n" >> "$OUTPUT_FILE"
done < firehol_level1.netset

# Clean up the downloaded file
rm -f firehol_level1.netset
echo "Blacklist processing completed."
