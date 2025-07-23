#!/bin/bash

LOGFILE="data/conntrack.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

mkdir -p data

echo "=== $DATE ===" >> "$LOGFILE"
sudo conntrack -L -o extended >> "$LOGFILE"
echo "" >> "$LOGFILE"

