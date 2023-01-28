#!/bin/bash

set -euo pipefail
IFS=$'\n'

profile=releng
verbose=false

for arg in $@; do
    case $arg in
        -v|--verbose) verbose=true
    esac
done

[ -d profile/ ] && {
    echo "Removing existing profile..."
    rm -rf profile/
}

echo "Copying profile $profile..."
cp -r /usr/share/archiso/configs/$profile/ profile/

echo "Applying overrides..."
pushd override/ &>/dev/null
find . -type f -not -name "*:diff" -exec cp {} ../profile/{} \;
find . -type f -name "*:diff" -exec sh -c "patch -f $($verbose || echo '-s') ../profile/\$(basename {} :diff) {}" \;
popd &>/dev/null