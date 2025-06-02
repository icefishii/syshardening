#!/usr/bin/env bash

set -euo pipefail

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

echo "[+] Installing rkhunter"
sudo apt install -y rkhunter

echo "[+] Updating rkhunter data files"
sudo rkhunter --update

echo "[+] Running initial rkhunter check"
sudo rkhunter --check --sk

echo "[+] Setting up daily rkhunter cron job"

sudo tee /etc/cron.daily/rkhunter-check > /dev/null << 'EOF'
#!/usr/bin/env bash
/usr/bin/rkhunter --check --quiet --skip-keypress | mail -s "rkhunter daily check report" root
EOF

sudo chmod +x /etc/cron.daily/rkhunter-check

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
