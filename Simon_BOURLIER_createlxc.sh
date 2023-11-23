#!/bin/bash

set -euo pipefail

###########################
# Variables et constantes #
###########################
GREEN="\033[0;32m"
RED="\033[0;31m"
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
success() {
    printf -- "%b%%s%b\n" "$GREEN" "$1" "$RESET_COLOR"
}

error() {
    printf >&2 -- "%bError: %s%b\n" "$RED" "$1" "$RESET_COLOR"
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
while getopts "n:d:r:a:u:ah" opt; do
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
    a) # Automatic connection
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

sudo lxc-create -t download -n $lxc_name -- -d $distr_name -r $release -a $arch || error "Erreur lors de la création du conteneur lxc"
sudo lxc-start -n $lxc_name || error "Erreur lors du lancement du conteneur lxc"

printf -- "\n%s\n\n" "En attente de connexion internet ..."
while ! sudo lxc-attach -n $lxc_name -- ping -c 1 8.8.8.8 > /dev/null 2>&1; do
    sleep 1
done

sudo lxc-attach -n $lxc_name -- bash -c '
  echo "fr_FR.UTF-8 UTF-8" > /etc/locale.gen &&
  locale-gen &&
  update-locale LANG=fr_FR.UTF-8 &&
  apt update -qq > /dev/null 2>&1 &&
  apt install -yqq ssh sudo > /dev/null 2>&1 &&
  useradd '"$username"' &&
  echo "'"$username"':'"$passwd"'" | chpasswd
' && sucess "Paramétrage effectué avec succès" || error "Erreur lors du paramétrage du conteneur lxc"

container_ip=$(sudo lxc-info -n $lxc_name | awk '/IP:/ {print $2}')
cat <<-EOF

    You can now connect with ssh to the container : 

    | Username :    user
    | Password :    user

    command :
        ssh user@$container_ip

EOF
[ "$auto_connect" == true ] && ssh user@$container_ip
sudo lxc-ls -f

# sudo lxc-ls -f | awk '/RUNNING/ {print $1}' | xargs -I {} sudo lxc-stop -n {} && sudo lxc-ls -f | awk '/STOPPED/ {print $1}' | xargs -I {} sudo lxc-destroy -n {}
