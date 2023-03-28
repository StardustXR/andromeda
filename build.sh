#!/bin/bash

#? safer bash options
set -euo pipefail
export IFS=$'\n'

#? variables
dir="$(dirname $(readlink -f $0))"
chaoticaur_key=FBA220DFC880C036

#? check if work/ exists and is mounted as tmpfs
function has_tmpfs() {
    for path in $(mount | grep -oP '(?<=on ).+(?= type)'); do
        [ "$(readlink -f $path)" = "$dir/work" ] && return 0
    done
    return 1
}

#? remind user to repatch profile/
read -p 'update profile before building? (Y/n) ' res
[ "$res" = n ] || [ "$res" = N ] || ./patch.sh && echo

#? create and mount work/ as tmpfs
has_tmpfs || {
    mkdir -p work
    echo 'Mounting work/ as tmpfs...'
    sudo mount -t tmpfs tmpfs work
}

#? ensure Chaotic-AUR PGP key is installed on host
$(pacman-key --list-sigs $chaoticaur_key &>/dev/null) || {
    echo 'PGP key for Chaotic-AUR not installed, receiving and signing...'
    sudo pacman-key --recv-key $chaoticaur_key --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key $chaoticaur_key
}

#? fallback to standard filesystem if there's less than 10GB available in tmpfs
[ $(df work --output=avail | tail -n1) -lt 10737418 ] && sudo umount work/

#? build archiso
sudo mkarchiso -v -w work/ profile/

#? unmount work/ if it's mounted
has_tmpfs && {
    echo 'Unmounting work/...'
    sudo umount work
} || exit
