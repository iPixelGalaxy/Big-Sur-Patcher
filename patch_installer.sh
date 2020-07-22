#!/bin/bash -e
# Thanks ASentientBot for Hax.dylib
echo "Big Sur installer patch tool v0.2.1 by iPixelGalaxy (Inspired and based off ParrotGeeks Patcher)"
if [ "x$1" = "x" ] ;then
	echo ERROR: You need to pass in the installer disk as an argument
	exit 1
fi
theapp="/Volumes/Install macOS Big Sur Beta/Install macOS Big Sur Beta.app"
disk=$(diskutil list "$1" | head -c11)
OS=$(sw_vers -productVersion)
echo macOS $OS Detected

#Functions

Unpatch() {
	if [[ -e "$theapp/Contents/MacOS/InstallAssistant.app" ]]; then
	echo Detected already patched installer, unpatching before updating patches
	mv -f "$theapp" "/Volumes/Install macOS Big Sur Beta/.tmp.app"
	mv -f "/Volumes/Install macOS Big Sur Beta/.tmp.app/Contents/MacOS/InstallAssistant.app" "$theapp"
	rm -rf "/Volumes/Install macOS Big Sur Beta/.tmp.app"
	echo Unpatched, continuing with updated patch
	fi }

Patch() {
	Unpatch
	echo Patching "$1"
	cd "$(dirname "$0")"
	cat com.apple.Boot.plist > "/Volumes/Install macOS Big Sur Beta"/Library/Preferences/SystemConfiguration/com.apple.Boot.plist
	mv -f "$theapp" "/Volumes/Install macOS Big Sur Beta/.tmp.app"
	cp -r "trampoline.app" "$theapp"
	mv -f "/Volumes/Install macOS Big Sur Beta/.tmp.app" "$theapp/Contents/MacOS/InstallAssistant.app"
	cp "$theapp/Contents/MacOS/InstallAssistant.app/Contents/Resources/InstallAssistant.icns" "$theapp/Contents/Resources/InstallAssistant.icns"
	cp "$theapp/Contents/MacOS/InstallAssistant" "$theapp/Contents/MacOS/InstallAssistant_plain"
	cp "$theapp/Contents/MacOS/InstallAssistant" "$theapp/Contents/MacOS/InstallAssistant_springboard"
	touch "$theapp" 
	}

Create_Installer() {
	if [ ! -e /Applications/Install\ macOS\ Big\ Sur\ Beta.app ]; then
    	if [ ! -e ~/InstallAssistant.pkg ]; then
    		curl http://swcdn.apple.com/content/downloads/04/19/001-23553-A_1O2KYISWEK/58hrejz970xje070in5dorjoovnmw61x03/InstallAssistant.pkg --output ~/InstallAssistant.pkg
    	fi
		echo Installing InstallAssistant.pkg...
		echo Password Required:
		sudo installer -verboseR -pkg ~/InstallAssistant.pkg -target /
	fi
	echo Making Installer USB and Patching
	diskutil eraseDisk JHFS+ Install $disk 
	diskutil splitPartition /Volumes/Install jhfs+ Patch 25m jhfs+ Install R
	echo Running macOS Installer, Password Required
	sudo /Applications/Install\ macOS\ Big\ Sur\ Beta.app/Contents/Resources/createinstallmedia --volume /Volumes/Install --nointeraction
	}

Confirmation() {
	read -p "(press y to continue):" -n 1 -r
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		exit
	fi
	echo ""
}
#Patcher

if [ ! $OS = "10.16" ]; then			
	echo "This patcher was designed to work on all versions but a command was overlooked that only worked on Big Sur, because you are on macOS Catalina or lower another command must be run, this will download a clean copy of macOS Big Sur Beta 2 (if you don't already have it in your /Applications/ folder), if you do, your USB disk that you dragged in will be formatted and split correctly, after this installer the proccess will be the exact same as the video. Running this installer on Big Sur will be the same as the video. Do you wish to continue formatting your USB drive?"
	Confirmation
	Create_Installer
fi
if [ ! -e /Volumes/Install\ macOS\ Big\ Sur\ Beta/Install\ macOS\ Big\ Sur\ Beta.app ]; then
	echo "You are running Big Sur, however you do not have the Install macOS app created on your USB, would you like this patch tool to do it for you?"
	Confirmation
	Create_Installer
fi
Patch
if [ ! -e /Volumes/Patch/ ]; then
	if [ $OS = "10.16" ];then
		diskutil resizeVolume "$1" 15.0GB 
		diskutil addPartition "$1" HFS+J Patch 100m
	fi
fi
if [ ! -e /Volumes/Patch/kexts ]; then
	mkdir "/Volumes/Patch/kexts"
	cp -r "IO80211Family.kext" "/Volumes/Patch/kexts/IO80211Family.kext"
	cp -r "patch.sh" "/Volumes/Patch/patch.sh"
	sync
fi

echo Done, the installer "$1" is now patched for unsupported Macs

