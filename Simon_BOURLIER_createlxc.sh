#!/bin/bash

set -euo pipefail

myself=$(basename "$0") # Nom du script

[ -z "$(dpkg -l | grep -w 'lxc') | grep -w "lxc")" ] && sudo apt install -qq lxc 
[ -z "$(grep '^lxc\.net\.0\.hwaddr.*xx:xx:xx$' /etc/lxc/default.conf)" ] && sudo sed -i '/lxc.net.0.flags = up/a lxc.net.0.hwaddr = 00:16:3e:xx:xx:xx' /etc/lxc/default.conf
sudo lxc-create -t download -n c1 -- -d debian -r bullseye -a amd64
sudo lxc-start -n c1
sudo lxc-attach -n c1
dpkg-reconfigure locales
apt update
apt install ssh sudo
adduser user
adduser user sudo
