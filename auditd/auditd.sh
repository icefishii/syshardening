#!/usr/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "[*] Installing auditd..."
sudo apt update
sudo apt install -y auditd audispd-plugins

echo "[*] Enabling and starting auditd service..."
sudo systemctl enable auditd
sudo systemctl start auditd

echo "[*] Setting max log file size and number of rotated logs..."
sudo sed -i 's/^max_log_file = .*/max_log_file = 50/' /etc/audit/auditd.conf
sudo sed -i 's/^num_logs = .*/num_logs = 5/' /etc/audit/auditd.conf
sudo sed -i 's/^space_left_action = .*/space_left_action = email/' /etc/audit/auditd.conf
sudo sed -i 's/^action_mail_acct = .*/action_mail_acct = root/' /etc/audit/auditd.conf

echo "[*] Adding basic audit rules..."
cat << 'EOF' | sudo tee /etc/audit/rules.d/hardening.rules > /dev/null
# Monitor /etc/passwd and /etc/shadow for changes
-w /etc/passwd -p wa -k passwd_changes
-w /etc/shadow -p wa -k shadow_changes

# Monitor user/group changes
-w /etc/group -p wa -k group_changes
-w /etc/gshadow -p wa -k gshadow_changes

# Monitor sudo commands
-w /var/log/sudo.log -p rwxa -k sudo_log

# Monitor nginx configuration changes
-w /etc/nginx/ -p wa -k nginx_conf

# Monitor execution of binaries in /bin and /usr/bin
-w /bin/ -p x -k bin_exec
-w /usr/bin/ -p x -k usrbin_exec
EOF

echo "[*] Setting correct permissions for audit rules..."
sudo chmod 640 /etc/audit/rules.d/hardening.rules

echo "[*] Reloading audit rules..."
sudo augenrules --load

echo "[*] Checking auditd status..."
sudo auditctl -s

echo "[+] auditd installed and configured successfully."
