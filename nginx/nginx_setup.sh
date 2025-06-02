#!/usr/bin/env bash

set -euo pipefail

DOMAIN="syshardening.lampart.dev"
EMAIL="admin@$DOMAIN"
NGINX_CONF_SRC="./nginx.conf"
NGINX_SITE_CONF_SRC="./denoapp.nginx.conf"
NGINX_CONF_DST="/etc/nginx/nginx.conf"
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
  --preferred-challenges tls-alpn-01 \
  --non-interactive \
  --agree-tos \
  -m "$EMAIL" \
  -d "$DOMAIN"

echo "[+] Copying hardened global NGINX config..."
sudo cp "$NGINX_CONF_SRC" "$NGINX_CONF_DST"

echo "[+] Deploying application site config..."
sudo cp "$NGINX_SITE_CONF_SRC" "$NGINX_SITE_CONF_DST"
sudo ln -sf "$NGINX_SITE_CONF_DST" "$NGINX_ENABLED_LINK"

echo "[+] Testing and restarting NGINX with new configuration..."
sudo nginx -t
sudo systemctl start nginx

echo "[+] Verifying certbot renewal setup..."
sudo certbot renew --dry-run --preferred-challenges tls-alpn-01

echo "[✔] All done. Your site is live at https://$DOMAIN"
