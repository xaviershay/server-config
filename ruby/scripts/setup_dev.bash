#!/bin/bash

# chruby
wget https://github.com/postmodern/chruby/releases/download/v0.3.9/chruby-0.3.9.tar.gz
tar -xzvf chruby-0.3.9.tar.gz
cd chruby-0.3.9/
sudo make install

# ruby-install
wget https://github.com/postmodern/ruby-install/releases/download/v0.9.4/ruby-install-0.9.4.tar.gz
tar -xzvf ruby-install-0.9.4.tar.gz
cd ruby-install-0.9.4/
sudo make install

ruby-install # Download ruby versions
ruby-install 3.4.1

echo "source /usr/local/share/chruby/chruby.sh; chruby 3.4.1" >> ~/.bashrc

# Terraform
apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt-get install terraform

# TODO: Copy over .aws/ config and credentials
# TODO: SSH agent forwarding, or copy over credentials