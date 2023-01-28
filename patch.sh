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

#// apply overrides and patches \\\\\\\\# 
pushd override/ &>/dev/null
echo "Applying overrides..."
find . -type f -not -name "*:diff" -exec cp {} ../profile/{} \; $($verbose && echo -print)

echo "Applying patches..."
find . -type f -name "*:diff" -exec \
    sh -c 'patch -fs ../profile/$(basename {} :diff) {}' \; $($verbose && echo -print)
popd &>/dev/null
#\\\\\\\\ apply overrides and patches //#
