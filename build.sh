#!/bin/bash

#? safer bash options
set -euo pipefail
IFS=$'\n'

mkdir -p work/
sudo mount -t tmpfs tmpfs work/

#? fallback to standard filesystem if there's less than 4GB available in tmpfs
[ $(df work --output=avail | tail -n1) -lt 4098526 ] && sudo umount work/

sudo mkarchiso -v -w work/ profile/
