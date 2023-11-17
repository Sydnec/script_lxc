#!/bin/bash

set -euo pipefail

myself=$(basename "$0") # Nom du script

sudo apt install lxc
sudo vi /etc/lxc/default.conf
sudo lxc-create -t download -n c1 -- -d debian -r bullseye -a amd64
sudo lxc-start -n c1
sudo lxc-attach -n c1
dpkg-reconfigure locales
apt update
apt install ssh sudo
adduser user
adduser user sudo
