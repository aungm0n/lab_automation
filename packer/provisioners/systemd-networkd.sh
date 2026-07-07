#!/bin/bash
set -e

# Disable legacy networking stack
systemctl disable networking || true

# Enable modern networking
systemctl enable systemd-networkd
systemctl enable systemd-resolved

# DNS fix
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# Remove old static interface config (critical)
rm -f /etc/network/interfaces

# Ensure networkd config exists
mkdir -p /etc/systemd/network

cat > /etc/systemd/network/20-wired.network <<EOF
[Match]
Type=ether

[Network]
DHCP=yes
EOF