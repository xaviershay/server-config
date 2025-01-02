#!/bin/bash

set -ex

rm -Rf /usr/local/bin/blocky /tmp/blocky
curl -L https://github.com/0xERR0R/blocky/releases/download/v0.24/blocky_v0.24_Linux_arm64.tar.gz \
  | tar xz -C /tmp
sudo mv /tmp/blocky /usr/local/bin/blocky
sudo setcap 'cap_net_bind_service=+ep' /usr/local/bin/blocky