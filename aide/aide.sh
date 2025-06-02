#!/usr/bin/bash

set -e

echo "[*] Installing AIDE..."
sudo apt update
sudo apt install -y aide

AIDE_CONF="/etc/aide/aide.conf"

echo "[+] Backing up current aide.conf to aide.conf.bak"
sudo cp "$AIDE_CONF" "${AIDE_CONF}.bak"

echo "[+] Updating Checksums line to use sha512"
sudo sed -i -r 's/^Checksums\s*=.*/Checksums = sha512/' "$AIDE_CONF"

echo "[*] Initializing AIDE database..."
sudo aideinit

echo "[*] Replacing the default database with the initialized one..."
sudo cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db

echo "[*] Creating a daily cron job to check system integrity..."
cat << 'EOF' | sudo tee /etc/cron.daily/aide-check > /dev/null
#!/usr/bin/bash
# AIDE daily check script

LOGFILE="/var/log/aide/aide-check.log"
mkdir -p "$(dirname "$LOGFILE")"

echo "[*] Running AIDE integrity check on $(date)" >> "$LOGFILE"
aide --check --config /etc/aide/aide.conf >> "$LOGFILE"
EOF

sudo chmod +x /etc/cron.daily/aide-check

echo "[*] Configuration complete. AIDE will now check file integrity daily."
