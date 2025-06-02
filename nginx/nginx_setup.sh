#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DOMAIN="syshardening.lampart.dev"
EMAIL="admin@$DOMAIN"

NGINX_CONF_SRC="$SCRIPT_DIR/nginx.conf"
NGINX_CONF_DST="/etc/nginx/nginx.conf"
NGINX_CONF_BACKUP="/etc/nginx/nginx.conf.bak"

NGINX_SITE_CONF_SRC="$SCRIPT_DIR/denoapp.nginx.conf"
NGINX_SITE_CONF_DST="/etc/nginx/sites-available/denoapp"
NGINX_ENABLED_LINK="/etc/nginx/sites-enabled/denoapp"

echo "[+] Installing NGINX and Certbot with TLS-ALPN support..."
sudo apt update
sudo apt install -y nginx certbot

echo "[+] Stopping NGINX temporarily for TLS-ALPN-01 challenge..."
sudo systemctl stop nginx

echo "[+] Requesting certificate using TLS-ALPN-01..."
sudo certbot certonly \
  --standalone \
  --nginx \
  --non-interactive \
  --agree-tos \
  -m "$EMAIL" \
  -d "$DOMAIN"

echo "[+] Backing up original NGINX config..."
sudo cp "$NGINX_CONF_DST" "$NGINX_CONF_BACKUP"

echo "[+] Replacing global NGINX config with hardened version..."
sudo cp "$NGINX_CONF_SRC" "$NGINX_CONF_DST"

echo "[+] Deploying site config for application..."
sudo cp "$NGINX_SITE_CONF_SRC" "$NGINX_SITE_CONF_DST"
sudo ln -sf "$NGINX_SITE_CONF_DST" "$NGINX_ENABLED_LINK"

echo "[+] Testing and restarting NGINX with new configuration..."
sudo nginx -t
sudo systemctl start nginx

#echo "[+] Verifying certbot renewal setup..."
#sudo certbot renew --dry-run --preferred-challenges tls-alpn-01

echo "[✔] NGINX hardened and site live at https://$DOMAIN"
