#!/bin/bash

LOGFILE="logs/conntrack.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "=== $DATE ===" >> "$LOGFILE"
sudo conntrack -L -o extended >> "$LOGFILE"
echo "" >> "$LOGFILE"

