#!/bin/bash

set -ex

sudo apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

# Hard-coding bookworm, since that's the matching Debian release. Hashicorp
# don't publish separate packages for Devuan.
RELEASE=bookworm

if [ "$(lsb_release -cs)" != "daedalus" ]; then
   echo "This script requires Devuan Daedalus" >&2
   exit 1
fi

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $RELEASE main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt-get update
sudo apt-get install terraform -y

# TODO: Copy over .aws/ config and credentials
# TODO: SSH agent forwarding, or copy over credentials


# Edit /etc/ssh/sshd_config
#   PermitRootLogin yes
#   PasswordAuthentication yes