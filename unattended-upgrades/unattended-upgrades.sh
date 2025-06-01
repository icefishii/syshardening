#!/usr/bin/bash

set -e

echo "=== Installing unattended-upgrades ==="
sudo apt update
sudo apt install -y unattended-upgrades

echo "=== Enabling unattended-upgrades timer ==="
sudo systemctl enable --now unattended-upgrades

# Read current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Determine distro info
DISTRO_CODENAME=$(lsb_release -sc)

echo "=== Preparing 50unattended-upgrades ==="
# Replace placeholder with actual codename
sed "s/\$(CODENAME)/$DISTRO_CODENAME/g" "$SCRIPT_DIR/50unattended-upgrades" | sudo tee /etc/apt/apt.conf.d/50unattended-upgrades > /dev/null

echo "=== Copying 20auto-upgrades ==="
sudo cp "$SCRIPT_DIR/20auto-upgrades" /etc/apt/apt.conf.d/20auto-upgrades

echo "=== Dry-run test ==="
sudo unattended-upgrades --dry-run --debug

echo "=== Setup complete ==="
