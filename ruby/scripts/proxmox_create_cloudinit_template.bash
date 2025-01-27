#!/bin/bash

set -ex

if [ $# -ne 3 ]; then
    echo "Usage: $0 VMID NAME IMAGE_URL"
    echo "Example: $0 100 debian-template https://download.debian.org/image.qcow2"
    exit 1
fi

VMID=$1
NAME=$2
IMAGE=$3
IMAGE_FILE=$(basename $IMAGE)
RESIZED_IMAGE_FILE=${IMAGE_FILE}.resized

cd

if [ ! -f "$IMAGE_FILE" ]; then
    wget $IMAGE
fi

cp $IMAGE_FILE $RESIZED_IMAGE_FILE
# Could make this customizable. Alpine image is 200Mb, this gets it up to 1Gb for some breathing room.
qemu-img resize $RESIZED_IMAGE_FILE +824M
qm create $VMID --name $NAME --memory 512 --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci
qm set $VMID --scsi0 local-lvm:0,import-from=/root/$RESIZED_IMAGE_FILE
qm set $VMID --ide2 local-lvm:cloudinit
qm set $VMID --boot order=scsi0
qm set $VMID --serial0 socket --vga serial0
qm template $VMID