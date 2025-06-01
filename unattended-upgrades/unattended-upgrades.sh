#!/usr/bin/bash

set -e

echo "=== Installing unattended-upgrades ==="
sudo apt update
sudo apt install -y unattended-upgrades

echo "=== Enabling unattended-upgrades timer ==="
sudo systemctl enable --now unattended-upgrades

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Copying 50unattended-upgrades (hardcoded for noble) ==="
sudo cp "$SCRIPT_DIR/50unattended-upgrades" /etc/apt/apt.conf.d/50unattended-upgrades

echo "=== Copying 20auto-upgrades ==="
sudo cp "$SCRIPT_DIR/20auto-upgrades" /etc/apt/apt.conf.d/20auto-upgrades

echo "=== Dry-run test ==="
sudo unattended-upgrades --dry-run --debug

echo "=== Setup complete ==="
