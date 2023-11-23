#!/bin/bash

set -euo pipefail

myself=$(basename "$0") # Nom du script
lxc_name="lxc_$(printf '%x\n' "$(date '+%Y%m%d%H%M%S')")"
distr_name="debian"
release="bullseye"
arch="amd64"
user="user"
passwd="user"

#############################
# Déclaration des fonctions #
#############################
display() {
    if [ "$no_logs" == false ]; then
        [ -n "$logs_dir" ] && printf -- "$(date '+[%d/%m/%Y-%H:%M:%S]') %s\n" "$1" || printf -- "%s\n" "$1"
    fi
}

error() {
    [ -n "$logs_dir" ] && printf >&2 -- "$(date '+[%d/%m/%Y-%H:%M:%S]') Error: %s\n" "$1" || printf >&2 -- "%Error: s\n" "$1"
    exit "$2"
}

usage() {
    if ! $show_usage; then
        cat <<-EOF
    Utilisation: $myself [-i repertoire_entree] [-o repertoire_sortie] [-m] [-e] [-s] [-n] [-l repertoire_logs] [-h]

    Options:
        -i : Chemin du répertoire d'entrée
        -o : Chemin du répertoire de sortie
        -m : Déplacer les fichiers au lieu de les copier
        -e : Ecrase les fichier de destintations s'ils existent déjà
        -s : Mode simulation (évalue les actions sans les exécuter)
        -n : (no log) Execute silencieusement
        -l : Rediriger les logs dans un dossier externe ("" pour prendre .logs/ par défaut)
        -h : Afficher ce message d'aide

    Exemple:
        $myself -mei /chemin/vers/repertoire_entree -o /chemin/vers/repertoire_sortie -l ./vers/logs

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
        user="$OPTARG"
        ;;
    p) # Password
        passwd="$OPTARG"
        ;;
    h) # Afficher le message d'aide
        usage
        exit 0
        ;;
    \?)
        error "Utilisation: $myself [-i repertoire_entree] [-o repertoire_sortie] [-m] [-s] [-n] [-l repertoire_logs] [-e] [-h]"
        ;;
    esac
done

[ -z "$(dpkg -l | grep -w 'lxc') | grep -w "lxc")" ] && sudo apt install -qq lxc
[ -z "$(grep '^lxc\.net\.0\.hwaddr.*xx:xx:xx$' /etc/lxc/default.conf)" ] && sudo sed -i '/lxc.net.0.flags = up/a lxc.net.0.hwaddr = 00:16:3e:xx:xx:xx' /etc/lxc/default.conf
sudo lxc-create -t download -n $lxc_name -- -d $distr_name -r $release -a $arch
sudo lxc-start -n $lxc_name
sudo lxc-attach -n $lxc_name -- bash -c '
  export DEBIAN_FRONTEND=noninteractive &&
  update-locale LANG=fr_FR.UTF-8 LC_ALL=fr_FR.UTF-8 > /dev/null 2>&1 &&
  apt update -qq > /dev/null 2>&1 &&
  apt install -yqq ssh sudo > /dev/null 2>&1
'
sudo lxc exec $lxc_name -- useradd "$username"
sudo lxc exec $lxc_name -- passwd $username $passwd
sudo lxc-ls -f

# sudo lxc-ls -f | awk '/RUNNING/ {print $1}' | xargs -I {} sudo lxc-stop -n {} && sudo lxc-ls -f | awk '/STOPPED/ {print $1}' | xargs -I {} sudo lxc-destroy -n {}
