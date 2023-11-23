#!/bin/bash

set -euo pipefail

myself=$(basename "$0") # Nom du script

if [ -z $(apt list --installed 2>/dev/null | grep -w "lxc") ]; then 
    sudo apt install -qq lxc;
fi
if [ -z $(grep '^lxc\.net\.0\.hwaddr.*xx:xx:xx$' /etc/lxc/default.conf) ]; then
    sudo sed -i '/lxc.net.0.flags = up/a lxc.net.0.hwaddr = 00:16:3e:xx:xx:xx' /etc/lxc/default.conf;
fi


# sudo lxc-create -t download -n c1 -- -d debian -r bullseye -a amd64
# sudo lxc-start -n c1
# sudo lxc-attach -n c1
# dpkg-reconfigure locales
# apt update
# apt install ssh sudo
# adduser user
# adduser user sudo
