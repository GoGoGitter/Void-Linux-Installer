#!/usr/bin/env bash

echo "-------------------------------------------------"
echo "-----          XBPS configuration          -----"
echo "-------------------------------------------------"
doas touch /etc/xbps.d/settings.conf
doas sh -c 'echo "architecture=x86_64-musl" >> /etc/xbps.d/settings.conf'
doas sh -c 'echo "repository=https://repo-us.voidlinux.org/current/musl" >> /etc/xbps.d/settings.conf'
doas sh -c 'echo "repository=https://repo-us.voidlinux.org/current/musl/nonfree" >> /etc/xbps.d/settings.conf'
doas sh -c 'echo "ignorepkg=sudo" >> /etc/xbps.d/settings.conf'
doas xbps-remove -Rfy sudo
doas xbps-install -Suy # XBPS must use a separate transaction to update itself.
doas xbps-install -Suy # If your update includes the xbps package, you will need to run the command a second time to apply the rest of the updates.
doas xbps-install -Sy void-repo-nonfree

echo "-------------------------------------------------"
echo "-----               Microcode               -----"
echo "-------------------------------------------------"

### for intel microcode
doas xbps-install -Sy intel-ucode # After installing this package, it is necessary to regenerate your initramfs.
VER=$(echo $(uname -r) | sed 's/\./ /2' | sed 's/ \w*$//') # uname -r outputs in the form x.y.z_a. This alters the string to the form x.y for the following command
doas xbps-reconfigure --force linux${VER} # For subsequent updates, the microcode will be added to the initramfs automatically.

### for amd microcode
#doas xbps-install -Sy linux-firmware-amd

echo "-------------------------------------------------"
echo "-----                  NTP                  -----"
echo "-------------------------------------------------"
doas xbps-install -Sy chrony
doas ln -s /etc/sv/chronyd /var/service/

echo "-------------------------------------------------"
echo "-----                 Cron                  -----"
echo "-------------------------------------------------"
doas xbps-install -Sy dcron
doas ln -s /etc/sv/dcron /var/service/
doas crontab -l > tmp.txt
echo "@monthly ID=remove-old-kernels vkpurge rm all" >> tmp.txt
cat tmp.txt | doas crontab -
rm tmp.txt

echo "-------------------------------------------------"
echo "-Session and Seat Management + Power Management--"
echo "-------------------------------------------------"
doas xbps-install -Sy elogind tlp
doas ln -s /etc/sv/elogind /var/service/
doas ln -s /etc/sv/tlp /var/service/

echo "-------------------------------------------------"
echo "-----           Graphics Drivers            -----"
echo "-------------------------------------------------"
doas xbps-install -Sy linux-firmware-intel mesa-dri
#intel-video-accel

#echo "export LIBVA_DRIVER_NAME=i965" >> ~/.xinitrc
