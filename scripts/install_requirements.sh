#!/bin/bash

# List of required packages
REQUIRED_TOOLS=("conntrack" "dnsutils" "curl" "jq")

echo "🔧 Checking and installing required tools..."

for tool in "${REQUIRED_TOOLS[@]}"; do
    echo -n "🔍 Checking $tool... "

    # Check if tool is installed
    if ! command -v "$tool" &> /dev/null; then
        echo "❌ Not found. Installing..."
        sudo apt-get update -qq
        sudo apt-get install -y "$tool"

        # Re-check installation
        if command -v "$tool" &> /dev/null; then
            echo "✅ $tool installed successfully."
        else
            echo "❌ Failed to install $tool. Please check manually."
        fi
    else
        echo "✅ Already installed."
    fi
done

echo "✅ All tools checked."

