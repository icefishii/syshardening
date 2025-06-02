#!/usr/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Define file paths relative to the script's location
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
AUDITD_CONFIG_FILE="$SCRIPT_DIR/auditd.conf"
HARDENING_RULES_FILE="$SCRIPT_DIR/hardening.rules"

echo "[*] Installing auditd..."
sudo apt update
sudo apt install -y auditd audispd-plugins

echo "[*] Enabling and starting auditd service..."
sudo systemctl enable auditd
sudo systemctl start auditd

echo "[*] Applying auditd.conf settings from $AUDITD_CONFIG_FILE..."
if [ -f "$AUDITD_CONFIG_FILE" ]; then
    # Clear existing common settings in auditd.conf to avoid duplicates
    sudo sed -i '/^max_log_file =/d' /etc/audit/auditd.conf
    sudo sed -i '/^num_logs =/d' /etc/audit/auditd.conf
    sudo sed -i '/^space_left_action =/d' /etc/audit/auditd.conf
    sudo sed -i '/^action_mail_acct =/d' /etc/audit/auditd.conf
    
    # Append the settings from the external file
    sudo cat "$AUDITD_CONFIG_FILE" >> /etc/audit/auditd.conf
    echo "    Settings applied."
else
    echo "    Warning: $AUDITD_CONFIG_FILE not found. Skipping auditd.conf configuration."
fi


echo "[*] Adding audit rules from $HARDENING_RULES_FILE..."
if [ -f "$HARDENING_RULES_FILE" ]; then
    # Clear existing rules in hardening.rules before adding new ones
    sudo cp "$HARDENING_RULES_FILE" /etc/audit/rules.d/hardening.rules
    echo "    Rules copied."
else
    echo "    Error: $HARDENING_RULES_FILE not found. Cannot apply audit rules."
    exit 1
fi

echo "[*] Setting correct permissions for audit rules..."
sudo chmod 640 /etc/audit/rules.d/hardening.rules

echo "[*] Reloading audit rules..."
sudo augenrules --load

echo "[*] Checking auditd status..."
sudo auditctl -s

echo "[+] auditd installed and configured successfully."