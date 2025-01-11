#!/bin/bash

set -ex

if [ -z "$1" ]; then
    echo "Error: HOST argument is required" >&2
    exit 1
fi

HOST="$1"

ssh root@$HOST 'bash -s' < scripts/remote_bootstrap.bash
export ALIAS=$(ssh root@$HOST hostname).local

# Remove any previous known fingerprints for this host
ssh-keygen -f ~/.ssh/known_hosts -R $ALIAS

# ssh-keyscan can't resolve .local for some reason, so hard coding
# temporarily into /etc/hosts
sudo sed -i "/${ALIAS}/d" /etc/hosts
echo "$HOST $ALIAS" | sudo tee -a /etc/hosts
ssh-keyscan $ALIAS >> ~/.ssh/known_hosts

# Re-use existing SSH credentials rather than generating new ones so that we
# don't also need to e.g. configure Github for new keys.
scp ~/.ssh/id_rsa* $HOST:.ssh/