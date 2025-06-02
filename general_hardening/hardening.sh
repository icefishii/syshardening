#!/usr/bin/env bash

set -xeuo pipefail

# Ensure script runs as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (e.g., sudo ./run_chkrootkit_daily.sh)"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[+] Installing libpam-tmpdir apt-show-versions"
sudo apt install -y libpam-tmpdir apt-show-versions

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

echo "[+] Installing chkrootkit..."
apt install -y chkrootkit

echo "[+] Logs..."
# Set log path
LOG_DIR="/var/log/chkrootkit"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/chkrootkit_$(date +%F_%H-%M-%S).log"

# Prepare cron job
CRON_CMD="/usr/sbin/chkrootkit >> $LOG_DIR/cron.log 2>&1"
CRON_JOB="0 3 * * * $CRON_CMD"

# Check if the cron job already exists
if crontab -l 2>/dev/null | grep -F "$CRON_CMD" >/dev/null; then
  echo "[+] Cron job already exists. Skipping addition."
else
  echo "[+] Adding daily cron job (every day at 3 AM)..."
  (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
  echo "[+] Cron job added."
fi

echo "[+] Setup complete. Logs are in $LOG_DIR"

echo "[+] Blacklisting unused protocols (dccp, sctp, rds, tipc)"
cat <<EOF | sudo tee /etc/modprobe.d/disable-unused-protocols.conf >/dev/null
blacklist dccp
blacklist sctp
blacklist rds
blacklist tipc
EOF

sudo update-initramfs -u

echo "[+] Setting password hashing to SHA512 with strong rounds in /etc/login.defs"

sudo sed -i 's/^#*ENCRYPT_METHOD.*/ENCRYPT_METHOD SHA512/' /etc/login.defs

if grep -q "^SHA_CRYPT_MIN_ROUNDS" /etc/login.defs; then
  sudo sed -i 's/^SHA_CRYPT_MIN_ROUNDS.*/SHA_CRYPT_MIN_ROUNDS 100000/' /etc/login.defs
else
  echo "SHA_CRYPT_MIN_ROUNDS 100000" | sudo tee -a /etc/login.defs
fi

echo "[+] Installing pam_pwquality for password strength checking"
sudo apt-get install -y libpam-pwquality

# Ensure pam_pwquality.so is included in common-password PAM file

PAM_FILE="/etc/pam.d/common-password"

if ! grep -q "pam_pwquality.so" "$PAM_FILE"; then
  echo "password requisite pam_pwquality.so retry=3" | sudo tee -a "$PAM_FILE"
fi

echo "[+] Disabling core dumps in /etc/security/limits.conf"
if ! grep -q "^\\s+hard\s+core\s+0" /etc/security/limits.conf; then
  echo " hard core 0" | sudo tee -a /etc/security/limits.conf
fi
if ! grep -q "^\\s+soft\s+core\s+0" /etc/security/limits.conf; then
  echo " soft core 0" | sudo tee -a /etc/security/limits.conf
fi

echo "[+] Installing and enabling process accounting (acct)..."
sudo apt update
sudo apt install -y acct

echo "[+] Enabling and starting acct service..."
sudo systemctl enable acct
sudo systemctl start acct
sudo systemctl status acct --no-pager

echo "[+] Installing sysstat..."
sudo apt install -y sysstat

echo "[+] Enabling sysstat data collection..."
sudo sed -i 's/^ENABLED="false"/ENABLED="true"/' /etc/default/sysstat

echo "[+] Enabling and restarting sysstat service..."
sudo systemctl enable sysstat
sudo systemctl restart sysstat
sudo systemctl status sysstat --no-pager

echo "[✓] Process accounting and sysstat are now active."