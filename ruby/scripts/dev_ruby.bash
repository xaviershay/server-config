#!/bin/bash

set -ex

# chruby
cd /tmp
rm -Rf chruby*
wget https://github.com/postmodern/chruby/releases/download/v0.3.9/chruby-0.3.9.tar.gz
tar -xzvf chruby-0.3.9.tar.gz
cd chruby-0.3.9/
sudo make install

# ruby-install
cd /tmp
rm -Rf ruby-install*
wget https://github.com/postmodern/ruby-install/releases/download/v0.9.4/ruby-install-0.9.4.tar.gz
tar -xzvf ruby-install-0.9.4.tar.gz
cd ruby-install-0.9.4/
sudo make install

ruby-install # Download ruby versions
ruby-install 3.4.1

LINE='source /usr/local/share/chruby/chruby.sh; chruby 3.4.1'
FILE=~/.bashrc
grep -qxF "$LINE" "$FILE" || echo "$LINE" >> "$FILE"