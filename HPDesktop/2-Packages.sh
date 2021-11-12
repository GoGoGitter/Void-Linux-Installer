#!/usr/bin/env bash

echo "-------------------------------------------------"
echo "-----              More Stuff               -----"
echo "-------------------------------------------------"
touch /etc/xbps.d/settings.conf
echo "architecture=x86_64-musl" >> /etc/xbps.d/settings.conf
echo "repository=https://repo-us.voidlinux.org/current/musl" >> /etc/xbps.d/settings.conf
echo "repository=https://repo-us.voidlinux.org/current/musl/nonfree" >> /etc/xbps.d/settings.conf
echo "ignorepkg=sudo" >> /etc/xbps.d/settings.conf

xbps-install -Su # XBPS must use a separate transaction to update itself.
xbps-install -Su # If your update includes the xbps package, you will need to run the command a second time to apply the rest of the updates.

### for intel microcode
#SSL_NO_VERIFY_PEER=true xbps-install -y void-repo-nonfree # Void has a nonfree repository for packages that don't have free licenses. It can enabled by installing the void-repo-nonfree package.
#SSL_NO_VERIFY_PEER=true xbps-install -y intel-ucode # After installing this package, it is necessary to regenerate your initramfs.
#VER=$(echo $(uname -r) | sed 's/\./ /2' | sed 's/ \w*$//')
#xbps-reconfigure --force linux${VER} # For subsequent updates, the microcode will be added to the initramfs automatically.

### for amd microcode
#SSL_NO_VERIFY_PEER=true xbps-install -y linux-firmware-amd # AMD CPUs and GPUs will automatically load the microcode, no further configuration required.
