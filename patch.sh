#!/bin/bash -e
echo Big Sur Wi-Fi Patch applier by iPixelGalaxy
if [ "x$1" = "x" ] ;then
	echo ERROR: You need to pass in the OS disk as an argument
	exit 1
fi
echo Patching "$1"
mount -uw "$1"
rm -rf "$1/System/Library/Extensions/IO80211Family.kext"
cp -r "/Volumes/Patch/kexts/IO80211Family.kext" "$1/System/Library/Extensions/IO80211Family.kext"
chown -R root:wheel "$1/System/Library/Extensions/"
chmod -R 755 "$1/System/Library/Extensions/"
cd "$1"
kmutil install --update-all --update-preboot --volume-root "$1"
