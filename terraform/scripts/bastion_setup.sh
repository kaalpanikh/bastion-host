#!/bin/bash

# Update system packages
yum update -y

# Install EPEL repository and fail2ban
amazon-linux-extras install epel -y
yum install -y fail2ban

# Configure fail2ban
cat << EOF > /etc/fail2ban/jail.local
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/secure
maxretry = 3
bantime = 3600
EOF

# Start and enable fail2ban
systemctl start fail2ban
systemctl enable fail2ban

# Configure SSH hardening
cat << EOF > /etc/ssh/sshd_config.d/hardening.conf
Protocol 2
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
X11Forwarding no
UseDNS no
AllowTcpForwarding yes
AllowAgentForwarding yes
GatewayPorts no
EOF

# Restart SSH service
systemctl restart sshd
