#!/usr/bin/bash

set -e

echo "[*] Installing AIDE..."
sudo apt update
sudo apt install -y aide

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
/usr/bin/aide.wrapper --check >> "$LOGFILE"
EOF

sudo chmod +x /etc/cron.daily/aide-check

echo "[*] Configuration complete. AIDE will now check file integrity daily."
