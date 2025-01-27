#!/bin/bash

set -ex

if [ $# -ne 3 ]; then
    echo "Usage: $0 SOURCE_ID ID NAME"
    echo "Example: $0 9001 103 dns1"
    exit 1
fi

SOURCE_ID=$1
VMID=$2
NAME=$3

qm clone $SOURCE_ID $VMID --name $NAME
qm set $VMID --ipconfig0 ip=dhcp,ip6=auto
qm set $VMID --sshkey xavier_id_rsa.pub