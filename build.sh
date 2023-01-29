#!/bin/bash

#? safer bash options
set -euo pipefail
IFS=$'\n'

function has_tmpfs() {
    mount | awk '{if ($3 == "$PWD/work/") { exit 0}} ENDFILE{exit -1}'
}

chaoticaur_key=FBA220DFC880C036

read -p 'update profile before building? (Y/n)' res
[ "$res" = n ] || [ "$res" = N ] || ./patch.sh && echo

has_tmpfs || {
    mkdir -p work/
    echo 'Mounting work/ as tmpfs...'
    sudo mount -t tmpfs tmpfs work/
}

$(pacman-key --list-sigs $chaoticaur_key &>/dev/null) || {
    echo 'PGP key for Chaotic-AUR not installed, receiving and signing...'
    sudo pacman-key --recv-key $chaoticaur_key --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key $chaoticaur_key
}

#? fallback to standard filesystem if there's less than 8GB available in tmpfs
[ $(df work --output=avail | tail -n1) -lt 8589935 ] && sudo umount work/

sudo mkarchiso -v -w work/ profile/

has_tmpfs && {
    echo 'Unmounting work/...'
    sudo umount work/
}