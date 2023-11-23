#!/bin/bash

set -euo pipefail

myself=$(basename "$0") # Nom du script

[ -z "$(dpkg -l | grep -w 'lxc') | grep -w "lxc")" ] && sudo apt install -qq lxc 
[ -z "$(grep '^lxc\.net\.0\.hwaddr.*xx:xx:xx$' /etc/lxc/default.conf)" ] && sudo sed -i '/lxc.net.0.flags = up/a lxc.net.0.hwaddr = 00:16:3e:xx:xx:xx' /etc/lxc/default.conf
sudo lxc-create -t download -n c1 -- -d debian -r bullseye -a amd64
sudo lxc-start -n c1
sudo lxc-attach -n c1 -- bash -c '
  update-locale LANG=fr_FR.UTF-8 LC_ALL=fr_FR.UTF-8
  apt update -qq > /dev/null 2>&1 && apt install -yqq ssh sudo > /dev/null 2>&1
'