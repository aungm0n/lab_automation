#!/bin/bash
set -e

cat > /etc/systemd/system/ssh-host-keys-regen.service <<'EOF'
[Unit]
Description=Regenerate missing SSH host keys
Before=ssh.service
ConditionPathExists=!/etc/ssh/ssh_host_rsa_key

[Service]
Type=oneshot
ExecStart=/usr/bin/ssh-keygen -A
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl enable ssh-host-keys-regen.service