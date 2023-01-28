#!/bin/bash

#? safer bash options
set -euo pipefail
IFS=$'\n'

#? variables
profile=releng
verbose=false

#// argument parsing \\\\\\\\#
for arg in $@; do
    case $arg in
        -v|--verbose) verbose=true
    esac
done
#\\\\\\\\ argument parsing //#

#? clean existing profile
[ -d profile/ ] && {
    echo "Removing existing profile..."
    rm -rf profile/
}

#? copy current version of profile from system
echo "Copying profile $profile..."
cp -r /usr/share/archiso/configs/$profile/ profile/

echo "Applying overrides..."
#// apply overrides and patches \\\\\\\\# 
pushd override/ &>/dev/null
find . -type f -not -name "*:diff" -exec cp {} ../profile/{} \;
find . -type f -name "*:diff" -exec sh -c "patch -f $($verbose || echo '-s') ../profile/\$(basename {} :diff) {}" \;
popd &>/dev/null
#\\\\\\\\ apply overrides and patches //#
