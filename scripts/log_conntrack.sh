#!/bin/bash

set -euo pipefail
exec > >(tee -a "$HOME/myrepos/ip-log-analyzer/debug.log") 2>&1
echo "Running at $(date)"


# Paths
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOGFILE="$BASE_DIR/logs/conntrack.log"
CACHEFILE="$BASE_DIR/data/.ip-dns-cache.txt"
IPINFO_CACHE="$BASE_DIR/data/.ipinfo-ip-cache.txt"
TMPFILE=$(mktemp)
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Load environment variables (e.g., IPINFO_TOKEN)
if [ -f "$BASE_DIR/.env" ]; then
    export $(grep -v '^#' "$BASE_DIR/.env" | xargs)
fi

# Confirm IPINFO_TOKEN is available
if [ -z "$IPINFO_TOKEN" ]; then
    echo "❌ IPINFO_TOKEN not set. Please check your .env file."
    exit 1
fi

# Ensure necessary files exist
mkdir -p "$BASE_DIR/data"
touch "$CACHEFILE" "$IPINFO_CACHE"

# IPInfo Lookup
ipinfo_lookup() {
    local ip=$1

    # Skip local IPs
    if [[ "$ip" =~ ^(127\.|10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[0-1])) ]]; then
        echo "Local $ip"
        return
    fi

    # Check IPInfo cache
    local cached=$(grep "^$ip " "$IPINFO_CACHE" | cut -d' ' -f2-)
    if [[ -n "$cached" ]]; then
        echo "$cached"
        return
    fi

    # Query IPInfo
    local json=$(curl -s --max-time 3 "https://ipinfo.io/$ip?token=$IPINFO_TOKEN")
    local org=$(echo "$json" | jq -r '.org // empty')
    local city=$(echo "$json" | jq -r '.city // empty')
    local country=$(echo "$json" | jq -r '.country // empty')

    if [[ -z "$org" && -z "$city" && -z "$country" ]]; then
        echo "UNKNOWN"
        return
    fi

    local label="$org, $city, $country"
    echo "$ip $label" >> "$IPINFO_CACHE"
    echo "$label"
}

# Hostname/DNS Resolution
resolve_ip() {
    local ip=$1

    if [[ "$ip" =~ ^127\. ]]; then echo "localhost"; return; fi
    if [[ "$ip" =~ ^(10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[0-1])) ]]; then echo "Local $ip"; return; fi

    local cached=$(grep "^$ip " "$CACHEFILE" | cut -d' ' -f2-)
    if [[ -n "$cached" ]]; then
        echo "$cached"
        return
    fi

    local rdns=$(dig +short -x "$ip" | sed 's/\.$//' | head -n 1)
    if [[ -n "$rdns" ]]; then
        echo "$ip $rdns" >> "$CACHEFILE"
        echo "$rdns"
        return
    fi

    local info=$(ipinfo_lookup "$ip")
    if [[ "$info" != "UNKNOWN" ]]; then
        echo "$ip $info" >> "$CACHEFILE"
    fi
    echo "$info"
}

# Logging
echo "=== $DATE ===" >> "$LOGFILE"
sudo conntrack -L -o extended | while read -r line; do
    src_ip=$(echo "$line" | grep -oP 'src=\K[0-9.]+')
    dst_ip=$(echo "$line" | grep -oP 'dst=\K[0-9.]+')

    [[ -z "$src_ip" || -z "$dst_ip" ]] && continue

    src_host=$(resolve_ip "$src_ip")
    dst_host=$(resolve_ip "$dst_ip")

    echo "$line" >> "$TMPFILE"
    echo "  ↳ src_host: $src_host | dst_host: $dst_host" >> "$TMPFILE"
done

cat "$TMPFILE" >> "$LOGFILE"
rm "$TMPFILE"
echo "" >> "$LOGFILE"

