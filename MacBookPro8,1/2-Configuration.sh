#!/usr/bin/env bash

echo "-------------------------------------------------"
echo "-----          XBPS configuration          -----"
echo "-------------------------------------------------"
doas mkdir -p /etc/xbps.d
doas touch /etc/xbps.d/settings.conf
doas sh -c 'echo "architecture=x86_64" >> /etc/xbps.d/settings.conf'
doas sh -c 'echo "ignorepkg=sudo" >> /etc/xbps.d/settings.conf'
doas xbps-remove -Rfy sudo
doas xbps-install -Suy # XBPS must use a separate transaction to update itself.
doas xbps-install -Suy # If your update includes the xbps package, you will need to run the command a second time to apply the rest of the updates.
doas xbps-install -Sy void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree
doas cp /usr/share/xbps.d/*-repository-*.conf /etc/xbps.d/
doas sed -i 's|https://alpha.de.repo.voidlinux.org|https://repo-us.voidlinux.org|g' /etc/xbps.d/*-repository-*.conf
doas xbps-install -S

echo "-------------------------------------------------"
echo "-----               Microcode               -----"
echo "-------------------------------------------------"
doas xbps-install -Sy intel-ucode # After installing this package, it is necessary to regenerate your initramfs.
VER=$(echo $(uname -r) | sed 's/\./ /2' | sed 's/ \w*$//') # uname -r outputs in the form x.y.z_a. This alters the string to the form x.y for the following command
doas xbps-reconfigure --force linux${VER} # For subsequent updates, the microcode will be added to the initramfs automatically.

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

echo "-------------------------------------------------"
echo "-----               Firewalls               -----"
echo "-------------------------------------------------"
doas xbps-install -Sy ufw
doas ln -s /etc/sv/ufw /var/service/
doas ufw enable

echo "-------------------------------------------------"
echo "-----      Session and Seat Management      -----"
echo "-------------------------------------------------"
rm /var/service/acpid
doas xbps-install -Sy elogind

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
doas xbps-install -Sy linux-firmware-intel mesa-dri intel-video-accel
echo "export LIBVA_DRIVER_NAME=i965" >> ~/.xinitrc

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
doas touch /etc/sv/bluetoothd/down
doas ln -s /etc/sv/bluetoothd /var/service/
#doas gpasswd -a ${USER} bluetooth

echo "-------------------------------------------------"
echo "-----                Flatpak                -----"
echo "-------------------------------------------------"
doas xbps-install -Sy flatpak
doas flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#echo "-------------------------------------------------"
#echo "-----               Printing                -----"
#echo "-------------------------------------------------"


echo "-------------------------------------------------"
echo "-----                libvirt                -----"
echo "-------------------------------------------------"
doas xbps-install -Sy libvirt virt-manager #virt-manager-tools
doas ln -s /etc/sv/libvirtd /var/service/
doas ln -s /etc/sv/virtlockd /var/service/
doas ln -s /etc/sv/virtlogd /var/service/

echo "-------------------------------------------------"
echo "-----               xbps-src                -----"
echo "-------------------------------------------------"
doas xbps-install -Sy git
mkdir ~/.git-clones
cd ~/.git-clones
git clone https://github.com/void-linux/void-packages.git
cd void-packages
./xbps-src binary-bootstrap
