#!/bin/bash

set -euo pipefail

myself=$(basename "$0") # Nom du script

[ -z $(apt list --installed 2>/dev/null | grep -w "lxc") ] && sudo apt install -qq lxc
# [ grep -q "^lxc\.net\.0\.hwaddr.*xx:xx:xx$" /etc/lxc/default.conf ] && echo "fait"


# sudo lxc-create -t download -n c1 -- -d debian -r bullseye -a amd64
# sudo lxc-start -n c1
# sudo lxc-attach -n c1
# dpkg-reconfigure locales
# apt update
# apt install ssh sudo
# adduser user
# adduser user sudo
