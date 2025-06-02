#!/usr/bin/bash

set -euo pipefail

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

APP_USER="denoapp"
# Use SCRIPT_DIR to define the source directory relative to the script
APP_SRC_DIR="$SCRIPT_DIR/webserver"
APP_DST_DIR="/opt/webserver"
APP_BINARY="todo-server"
DB_FILE="todos.db"
# Use SCRIPT_DIR to define the service file source relative to the script
SERVICE_FILE_SRC="$SCRIPT_DIR/denoapp.service"
SERVICE_FILE_DST="/etc/systemd/system/denoapp.service"

# Check that source files exist
if [[ ! -f "$APP_SRC_DIR/$APP_BINARY" ]] || [[ ! -f "$APP_SRC_DIR/$DB_FILE" ]]; then
    echo "Error: $APP_SRC_DIR must contain $APP_BINARY and $DB_FILE"
    exit 1
fi

if [[ ! -f "$SERVICE_FILE_SRC" ]]; then
    echo "Error: Missing service file: $SERVICE_FILE_SRC"
    exit 1
fi

echo "[+] Creating system user: $APP_USER"
if ! id "$APP_USER" &>/dev/null; then
    sudo useradd --system --no-create-home --shell /usr/sbin/nologin "$APP_USER"
else
    echo "    User $APP_USER already exists, skipping."
fi

echo "[+] Creating destination directory: $APP_DST_DIR"
sudo mkdir -p "$APP_DST_DIR"
sudo chown "$APP_USER:$APP_USER" "$APP_DST_DIR"

echo "[+] Copying files to $APP_DST_DIR"
sudo cp "$APP_SRC_DIR/$APP_BINARY" "$APP_SRC_DIR/$DB_FILE" "$APP_DST_DIR/"
sudo chown "$APP_USER:$APP_USER" "$APP_DST_DIR/$APP_BINARY" "$APP_DST_DIR/$DB_FILE"

echo "[+] Setting strict permissions"
sudo chmod 500 "$APP_DST_DIR/$APP_BINARY"
sudo chmod 600 "$APP_DST_DIR/$DB_FILE"
sudo chmod 700 "$APP_DST_DIR"
# This might be too broad or unnecessary depending on your system's default /opt permissions.
# Often /opt itself is already traversable. Only add if strictly needed and understood.
# sudo chmod +x /opt

echo "[+] Installing systemd service"
sudo cp "$SERVICE_FILE_SRC" "$SERVICE_FILE_DST"
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now denoapp.service

echo "[✔] Setup complete. Service status:"
sudo systemctl status denoapp.service --no-pager