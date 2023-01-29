#!/bin/bash

#? safer bash options
set -euo pipefail
IFS=$'\n'

read -p 'update profile before building? (Y/n)' res
[ $res != n ] && [ $res != N ] && ./patch.sh && echo

mkdir -p work/
sudo mount -t tmpfs tmpfs work/

#? fallback to standard filesystem if there's less than 4GB available in tmpfs
[ $(df work --output=avail | tail -n1) -lt 4098526 ] && sudo umount work/

sudo mkarchiso -v -w work/ profile/
