#!/bin/bash

set -euo pipefail

###########################
# Variables et constantes #
###########################
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RESET_COLOR="\033[0m"

myself=$(basename "$0") # Nom du script
lxc_name="lxc_$(printf '%x\n' "$(date '+%Y%m%d%H%M%S')")"
distr_name="debian"
release="bullseye"
arch="amd64"
username="user"
passwd="user"
auto_connect=false

#############################
# Déclaration des fonctions #
#############################
info() {
    printf -- "$BLUE[ INFOS ]$RESET_COLOR   %s\n" "$1"
}

success() {
    printf -- "$GREEN[SUCCESS]$RESET_COLOR   %s\n" "$1"
}

error() {
    printf >&2 -- "$RED[ ERROR ]$RESET_COLOR   %s\n" "$1"
    exit "$2"
}

usage() {
    if ! $show_usage; then
        cat <<-EOF
    Utilisation: $myself 
    
    Options:
        -n : 
        -d : 
        -r : 
        -a : 
        -u : 
        -h : Afficher ce message d'aide

    Exemple:
        $myself 
        
		EOF
        show_usage=true
    fi
}

#######################
# Lecture des options #
#######################
while getopts "n:d:r:a:u:h" opt; do
    case "$opt" in
    n) # Nom du contenaire
        lxc_name="$OPTARG"
        ;;
    d) # Distribution
        distr_name="$OPTARG"
        ;;
    r) # Release
        release="$OPTARG"
        ;;
    a) # Architecture
        arch="$OPTARG"
        ;;
    u) # Username
        username="$OPTARG"
        ;;
    p) # Password
        passwd="$OPTARG"
        ;;
    h) # Afficher le message d'aide
        usage
        exit 0
        ;;
    \?)
        error "Utilisation: $myself" 1
        ;;
    esac
done

if [ -z "$(dpkg -l | grep -w 'lxc' | grep -w "lxc")" ]; then
    info "Installing lxc"
    sudo apt install -y lxc >/dev/null 2>&1 && success "lxc intalled" || error "Failed lxc to settle in" 1
fi
if [ -z "$(grep '^lxc\.net\.0\.hwaddr.*xx:xx:xx$' /etc/lxc/default.conf)" ]; then
    info "Editing /etc/lxc/default.conf"
    sudo sed -i '/lxc.net.0.flags = up/a lxc.net.0.hwaddr = 00:16:3e:xx:xx:xx' /etc/lxc/default.conf >/dev/null 2>&1 && success "/etc/lxc/default.conf edited" || error "Failed to edit /etc/lxc/default.conf" 1
fi
if sudo lxc-info "$lxc_name" &>/dev/null; then error "There is already a container using the name \"$lxc_name\"" 1; fi


sudo lxc-create -t download -n $lxc_name -- -d $distr_name -r $release -a $arch >/dev/null 2>&1 && success "Container created" || error "lxc container failed to create" 1
sudo lxc-start -n $lxc_name && success "Container launched" || error "lxc container failed to launch" 1

info "Waiting internet connection"
while ! sudo lxc-attach -n $lxc_name -- ping -c 1 8.8.8.8 >/dev/null 2>&1; do
    sleep 1
done
success "Internet connection etablished"

sudo lxc-attach -n $lxc_name -- bash -c '
  echo "fr_FR.UTF-8 UTF-8" > /etc/locale.gen &&
  locale-gen &&
  update-locale LANG=fr_FR.UTF-8' >/dev/null 2>&1 && success "Keybord set up" || error "Failed to set up keyboard" 1

sudo lxc-attach -n $lxc_name -- bash -c '
  apt update &&
  apt install -y ssh sudo' >/dev/null 2>&1

sudo lxc-attach -n $lxc_name -- bash -c '
  useradd '"$username"' &&
  echo "'"$username"':'"$passwd"'" | chpasswd' >/dev/null 2>&1 && success "User $username added" || error "Failed to add user $username" 1

container_ip=$(sudo lxc-info -n $lxc_name | awk '/IP:/ {print $2}')
cat <<-EOF

    You can now connect with ssh to the container : 

    | Username :  $username
    | Password :  $passwd

    Command :
        ssh $username@$container_ip

EOF
sudo lxc-ls -f

# sudo lxc-ls -f | awk '/RUNNING/ {print $1}' | xargs -I {} sudo lxc-stop -n {} && sudo lxc-ls -f | awk '/STOPPED/ {print $1}' | xargs -I {} sudo lxc-destroy -n {}
