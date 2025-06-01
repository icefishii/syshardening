#!/usr/bin/bash

set -euo pipefail

APP_USER="denoapp"
APP_SRC_DIR="./webserver"
APP_DST_DIR="/opt/webserver"
APP_BINARY="todo-server"
DB_FILE="todos.db"
SERVICE_FILE_SRC="./denoapp.service"
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
sudo chmod +x /opt  # Ensure traversal is possible

echo "[+] Installing systemd service"
sudo cp "$SERVICE_FILE_SRC" "$SERVICE_FILE_DST"
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now denoapp.service

echo "[✔] Setup complete. Service status:"
sudo systemctl status denoapp.service --no-pager
