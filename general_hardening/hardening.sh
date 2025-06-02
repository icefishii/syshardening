#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[+] Installing libpam-tmpdir apt-listbugs apt-listchanges"
sudo apt install -y libpam-tmpdir apt-listbugs apt-listchanges

echo "[+] Copying sysctl hardening config"
sudo cp "$SCRIPT_DIR/99-hardening.conf" /etc/sysctl.d/99-hardening.conf

echo "[+] Applying sysctl settings"
sudo sysctl --system
