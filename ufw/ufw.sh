#!/usr/bin/bash
set -e

echo "=== Installing and configuring UFW ==="

# Install UFW if not already installed
if ! command -v ufw &> /dev/null; then
    echo "Installing ufw..."
    sudo apt update
    sudo apt install -y ufw
fi

echo "Resetting UFW to default..."
sudo ufw --force reset

echo "Setting default policies (deny all incoming, deny all outgoing)..."
sudo ufw default deny incoming
sudo ufw default deny outgoing

echo "Allowing outgoing DNS (for domain name resolution)..."
sudo ufw allow out 53

echo "Allowing outgoing HTTP (port 80) and HTTPS (port 443)..."
sudo ufw allow out 80
sudo ufw allow out 443

echo "Allowing incoming SSH (port 22)..."
sudo ufw allow 22/tcp

echo "Allowing incoming HTTP (port 80) and HTTPS (port 443)..."
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

echo "Enabling UFW..."
sudo ufw --force enable

echo "UFW status:"
sudo ufw status verbose

echo "=== UFW configuration complete ==="
