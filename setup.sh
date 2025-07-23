#!/bin/bash

echo "🔧 Starting full setup..."

# Run dependency installer
echo "📦 Installing requirements..."
bash scripts/install_requirements.sh || { echo "❌ Dependency installation failed"; exit 1; }

# Create folders
echo "📁 Creating project directories..."
mkdir -p data logs scripts bin

# Make scripts executable
chmod +x scripts/*.sh

# Optional: Copy or symlink logging script to /usr/local/bin
echo "🔗 Linking main logger..."
sudo ln -sf "$PWD/scripts/log_conntrack.sh" /usr/local/bin/log_conntrack

# Done
echo "✅ Setup complete!"
echo "ℹ️  You can now run:"
echo "    log_conntrack           # To collect annotated logs"
echo "    scripts/summarize_ips.sh # To extract summary CSV"

