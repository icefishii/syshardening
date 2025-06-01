#!/usr/bin/bash

# Script to attach Ubuntu Pro and enable all security features except USG

set -e

# Check for token argument
if [ -z "$1" ]; then
    echo "Usage: $0 <UBUNTU_PRO_TOKEN>"
    exit 1
fi

TOKEN="$1"

# Attach Ubuntu Pro
sudo pro attach "$TOKEN"

# Enable security features (excluding usg)
SECURITY_FEATURES=(
    esm-infra
    esm-apps
    livepatch
    fips
    fips-updates
    cis
    kernel-livepatch
)

for feature in "${SECURITY_FEATURES[@]}"; do
    if pro status | grep -q "$feature.*disabled"; then
        echo "Enabling $feature..."
        sudo pro enable "$feature"
    else
        echo "$feature already enabled or not available."
    fi
done

echo "Ubuntu Pro attached and security features enabled."