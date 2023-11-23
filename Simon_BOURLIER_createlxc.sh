#!/bin/bash

set -euo pipefail

myself=$(basename "$0") # Nom du script

if dpkg-query -l lxc &> /dev/null; then
    echo "oui"
else
    sudo apt install lxc
    echo "non"
fi
# sudo lxc-create -t download -n c1 -- -d debian -r bullseye -a amd64
# sudo lxc-start -n c1
# sudo lxc-attach -n c1
# dpkg-reconfigure locales
# apt update
# apt install ssh sudo
# adduser user
# adduser user sudo
