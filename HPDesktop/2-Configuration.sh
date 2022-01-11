#!/usr/bin/env bash

echo "-------------------------------------------------"
echo "-----          XBPS configuration          -----"
echo "-------------------------------------------------"
doas touch /etc/xbps.d/settings.conf
doas sh -c 'echo "architecture=x86_64" >> /etc/xbps.d/settings.conf'
doas sh -c 'echo "repository=https://repo-us.voidlinux.org/current" >> /etc/xbps.d/settings.conf'
doas sh -c 'echo "repository=https://repo-us.voidlinux.org/current/nonfree" >> /etc/xbps.d/settings.conf'
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
echo "-----                Logging                -----"
echo "-------------------------------------------------"
doas xbps-install -Sy socklog-void
doas ln -s /etc/sv/socklog-unix /var/service/
doas ln -s /etc/sv/nanoklogd /var/service/

echo "-------------------------------------------------"
echo "-----                 Cron                  -----"
echo "-------------------------------------------------"
doas xbps-install -Sy dcron
doas ln -s /etc/sv/dcron /var/service/

echo "-------------------------------------------------"
echo "-----          Solid State Drives           -----"
echo "-------------------------------------------------"
doas crontab -l > tmp.txt
echo "@daily ID=TRIM fstrim /" >> tmp.txt
cat tmp.txt | doas crontab -
rm tmp.txt

#echo "-------------------------------------------------"
#echo "-----               Security                -----"
#echo "-------------------------------------------------"


echo "-------------------------------------------------"
echo "-----                  NTP                  -----"
echo "-------------------------------------------------"
doas xbps-install -Sy chrony
doas ln -s /etc/sv/chronyd /var/service/

echo "-------------------------------------------------"
echo "-----         Removing old kernels          -----"
echo "-------------------------------------------------"
doas crontab -l > tmp.txt
echo "@monthly ID=remove-old-kernels vkpurge rm all" >> tmp.txt
cat tmp.txt | doas crontab -
rm tmp.txt

echo "-------------------------------------------------"
echo "-----           Power Management            -----"
echo "-------------------------------------------------"
doas xbps-install -Sy tlp
doas ln -s /etc/sv/tlp /var/service/
doas sed -i 's/#SATA_LINKPWR_DENYLIST=.*/SATA_LINKPWR_DENYLIST="host0"/' /etc/tlp.conf
doas sed -i 's/#AHCI_RUNTIME_PM_ON_BAT=.*/AHCI_RUNTIME_PM_ON_BAT=on/' /etc/tlp.conf

echo "-------------------------------------------------"
echo "-----               Network                 -----"
echo "-------------------------------------------------"
doas xbps-install -Sy broadcom-wl-dkms

#echo "-------------------------------------------------"
#echo "-----               Firewalls               -----"
#echo "-------------------------------------------------"

echo "-------------------------------------------------"
echo "-----Session and Seat Management-----"
echo "-------------------------------------------------"
doas xbps-install -Sy elogind tlp
doas ln -s /etc/sv/elogind /var/service/
doas ln -s /etc/sv/tlp /var/service/
sed -i 's/#SATA_LINKPWR_DENYLIST=.*/SATA_LINKPWR_DENYLIST="host0"/' /etc/tlp.conf
sed -i 's/#AHCI_RUNTIME_PM_ON_BAT=.*/AHCI_RUNTIME_PM_ON_BAT=on/' /etc/tlp.conf

echo "-------------------------------------------------"
echo "-----                 Xorg                  -----"
echo "-------------------------------------------------"
doas xbps-install -Sy xorg
cp /etc/X11/xinit/xinitrc ~/.xinitrc
sed -i '/&$/d' ~/.xinitrc
sed -i '/^exec/d' ~/.xinitrc

echo "-------------------------------------------------"
echo "-----           Graphics Drivers            -----"
echo "-------------------------------------------------"
doas xbps-install -Sy linux-firmware-intel mesa-dri #intel-video-accel
#echo "export LIBVA_DRIVER_NAME=i965" >> ~/.xinitrc

#echo "-------------------------------------------------"
#echo "-----                 Fonts                 -----"
#echo "-------------------------------------------------"

#echo "-------------------------------------------------"
#echo "-----                 Icons                 -----"
#echo "-------------------------------------------------"

echo "-------------------------------------------------"
echo "-----               PipeWire                -----"
echo "-------------------------------------------------"
doas xbps-install -Sy pipewire #libspa-bluetooth
echo "pipewire &" >> ~/.xinitrc
echo "pipewire-pulse &" >> ~/.xinitrc

echo "-------------------------------------------------"
echo "-----               Bluetooth               -----"
echo "-------------------------------------------------"
doas xbps-install -Sy bluez
doas ln -s /etc/sv/bluetoothd /var/service/
doas touch /etc/sv/bluetoothd/down

echo "-------------------------------------------------"
echo "-----               xbps-src                -----"
echo "-------------------------------------------------"
doas xbps-install -Sy git
mkdir ~/.git-clones
cd ~/.git-clones
git clone https://github.com/void-linux/void-packages.git
cd void-packages
./xbps-src binary-bootstrap
