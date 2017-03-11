#!/usr/bin/env bash

ROOT=$(pwd);

sudo dpkg -i --force-depends *.deb;

# Unpack
tar -xvzf ruby-2.1.2.tar.gz;

cd ruby-2.1.2/;

# Compile from source
./configure --prefix=/usr/local;

make;

sudo make install;

# Make sure current user has access to installing gems
sudo chown -R $USER:$USER /usr/local/bin;

sudo chown -R $USER:$USER /usr/local/lib/ruby;

cd "$ROOT";

# Install bundler
gem install ./bundler-1.6.2.gem;
