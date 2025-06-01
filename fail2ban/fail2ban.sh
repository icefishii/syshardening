#!/usr/bin/bash

set -e

echo "=== Installing fail2ban ==="
sudo apt update
sudo apt install -y fail2ban

echo "=== Enabling and starting fail2ban ==="
sudo systemctl enable --now fail2ban

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Copying jail.local (SSH config) ==="
sudo cp "$SCRIPT_DIR/jail.local" /etc/fail2ban/jail.local

echo "=== Restarting fail2ban ==="
sudo systemctl restart fail2ban

echo "=== Checking fail2ban status ==="
sudo fail2ban-client status sshd || echo "SSH jail not active yet – check log"

echo "=== Done ==="
