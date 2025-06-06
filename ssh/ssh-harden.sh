#!/usr/bin/bash
set -e

# Determine the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Variables
SSHD_CONFIG_SRC="$SCRIPT_DIR/sshd_config"
SSHD_CONFIG_DEST="/etc/ssh/sshd_config"
USER="syshardening"
AUTHORIZED_KEYS="/home/$USER/.ssh/authorized_keys"

# Copy sshd_config
if [ -f "$SSHD_CONFIG_SRC" ]; then
    sudo cp "$SSHD_CONFIG_SRC" "$SSHD_CONFIG_DEST"
    sudo chmod 600 "$SSHD_CONFIG_DEST"
    sudo chown root:root "$SSHD_CONFIG_DEST"
else
    echo "sshd_config not found in $SCRIPT_DIR."
    exit 1
fi

# Ensure user exists
if ! id "$USER" &>/dev/null; then
    echo "User $USER does not exist."
    exit 1
fi

# Ensure .ssh directory exists
sudo -u "$USER" mkdir -p "/home/$USER/.ssh"
sudo -u "$USER" chmod 700 "/home/$USER/.ssh"

# Add SSH keys
cat <<EOF | sudo tee -a "$AUTHORIZED_KEYS" > /dev/null
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJa/6PklC39UEmwBILZlgQymkoaYPOgRn05UeQ7Pt7zK
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICA+XRVRUQ7YVxufc2I0vLsfbKHb3XAnZBauG5VVQnN
EOF

sudo chown "$USER:$USER" "$AUTHORIZED_KEYS"
sudo chmod 600 "$AUTHORIZED_KEYS"

echo "sshd_config copied and SSH keys added for $USER."

# Restart SSH service
if sudo systemctl restart ssh; then
    echo "SSH service restarted successfully."
else
    echo "Failed to restart SSH service."
    exit 1
fi