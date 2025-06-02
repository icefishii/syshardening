#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[+] Installing libpam-tmpdir apt-listbugs apt-listchanges"
sudo apt install -y libpam-tmpdir apt-listbugs apt-listchanges

echo "[+] Copying sysctl hardening config"
sudo cp "$SCRIPT_DIR/99-hardening.conf" /etc/sysctl.d/99-hardening.conf

echo "[+] Applying sysctl settings"
sudo sysctl --system

echo "[+] Securing file and cron permissions"

sudo chmod 600 /etc/at.deny /etc/crontab /etc/ssh/sshd_config
sudo chown root:root /etc/at.deny /etc/crontab /etc/ssh/sshd_config

for dir in /etc/cron.d /etc/cron.daily /etc/cron.hourly /etc/cron.weekly /etc/cron.monthly; do
    sudo chmod 700 "$dir"
    sudo chown root:root "$dir"
done

echo "[+] Setting hardened login banners"
BANNER_TEXT="Authorized access only. Unauthorized use is prohibited and will be prosecuted."
echo "$BANNER_TEXT" | sudo tee /etc/issue /etc/issue.net > /dev/null