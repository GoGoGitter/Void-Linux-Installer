#!/usr/bin/env bash

echo "-------------------------------------------------"
echo "-----          XBPS configuration          -----"
echo "-------------------------------------------------"
touch /etc/xbps.d/settings.conf
echo "architecture=x86_64-musl" >> /etc/xbps.d/settings.conf
echo "repository=https://repo-us.voidlinux.org/current/musl" >> /etc/xbps.d/settings.conf
echo "repository=https://repo-us.voidlinux.org/current/musl/nonfree" >> /etc/xbps.d/settings.conf
echo "ignorepkg=sudo" >> /etc/xbps.d/settings.conf
xbps-install -Suy # XBPS must use a separate transaction to update itself.
xbps-install -Suy # If your update includes the xbps package, you will need to run the command a second time to apply the rest of the updates.
xbps-install -Sy void-repo-nonfree

echo "-------------------------------------------------"
echo "-----               Microcode               -----"
echo "-------------------------------------------------"

### for intel microcode
#xbps-install -Sy intel-ucode # After installing this package, it is necessary to regenerate your initramfs.
#VER=$(echo $(uname -r) | sed 's/\./ /2' | sed 's/ \w*$//') # uname -r outputs in the form x.y.z_a. This alters the string to the form x.y for the following command
#xbps-reconfigure --force linux${VER} # For subsequent updates, the microcode will be added to the initramfs automatically.

### for amd microcode
#xbps-install -Sy linux-firmware-amd
