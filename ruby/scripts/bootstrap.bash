#!/bin/bash

# For use on a brand new machine with only a root login.
# * Creates a non-root user
# * Ensures hostname.local is advertised on the network (avahi)
#
# Usage:
#    ssh-copy-id $HOST
#    ssh root@$HOST 'bash -s' < bootstrap.bash

set -ex

USER="xavier"

# Ensure deps are present
apt install sudo avahi-daemon -y

if command -v systemctl >/dev/null 2>&1; then
   systemctl enable avahi-daemon
   systemctl start avahi-daemon
elif [ -f /etc/init.d/avahi-daemon ]; then
   /etc/init.d/avahi-daemon start
   update-rc.d avahi-daemon defaults
else
   echo "Error: Neither systemd nor sysvinit found" >&2
   exit 1
fi

# Create user and add to sudo group
useradd -m $USER || true
usermod -aG sudo $USER

echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER
chmod 440 /etc/sudoers.d/$USER

# Copy SSH keys
mkdir -p /home/$USER/.ssh
cp /root/.ssh/authorized_keys /home/$USER/.ssh/
chown -R $USER:$USER /home/$USER/.ssh
chmod 700 /home/$USER/.ssh
chmod 600 /home/$USER/.ssh/authorized_keys