#!/usr/bin/env bash

echo "-------------------------------------------------"
echo "-----          XBPS configuration          -----"
echo "-------------------------------------------------"
mkdir -p /etc/xbps.d
xbps-install -Suy -R $REPO/current
xbps-install -y -R $REPO/current void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree
cp /usr/share/xbps.d/*-repository-*.conf /etc/xbps.d/
sed -i 's|https://repo-default.voidlinux.org|$REPO|g' /etc/xbps.d/*-repository-*.conf

echo "-------------------------------------------------"
echo "-----          Firmware,Microcode           -----"
echo "-------------------------------------------------"
if [ "$(cat /proc/cpuinfo | grep AuthenticAMD | uniq)" != "" ]
then
  xbps-install -y linux-firmware-amd
elif [ "$(cat /proc/cpuinfo | grep GenuineIntel | uniq)" != "" ]
then
  xbps-install -y intel-ucode # After installing this package, it is necessary to regenerate your initramfs.
  VER=$(echo $(uname -r) | sed 's/\./ /2' | sed 's/ \w*$//') # uname -r outputs in the form x.y.z_a. This alters the string to the form x.y for the following command
  xbps-reconfigure --force linux$VER # For subsequent updates, the microcode will be added to the initramfs automatically.
fi

echo "-------------------------------------------------"
echo "-----           Users and Groups            -----"
echo "-------------------------------------------------"
useradd -m $NAME
gpasswd -a $NAME wheel
xbps-install -y opendoas
touch /etc/doas.conf
echo "permit nopass :wheel as root" > /etc/doas.conf

echo "-------------------------------------------------"
echo "-----                Logging                -----"
echo "-------------------------------------------------"
xbps-install -y socklog-void
ln -s /etc/sv/socklog-unix /var/service/
ln -s /etc/sv/nanoklogd /var/service/

echo "-------------------------------------------------"
echo "-----                 Cron                  -----"
echo "-------------------------------------------------"
xbps-install -y dcron
ln -s /etc/sv/dcron /var/service/

echo "-------------------------------------------------"
echo "-----          Solid State Drives           -----"
echo "-------------------------------------------------"
if [[ "$(cat /etc/default/grub | grep 'rd.luks.allow-discards')" != "" ]] || [[ "$(cat /etc/crypttab | grep discard)" != "" ]]
then
  touch /etc/cron.weekly/fstrim
  bash -c "echo -e '#!/bin/sh\n\nfstrim -v -a' > /etc/cron.weekly/fstrim"
  chmod u+x /etc/cron.weekly/fstrim
fi

#echo "-------------------------------------------------"
#echo "-----               AppArmor                -----"
#echo "-------------------------------------------------"


echo "-------------------------------------------------"
echo "-----             Date and Time             -----"
echo "-------------------------------------------------"
ln -sf /usr/share/zoneinfo/$TIME /etc/localtime
hwclock --systohc
xbps-install -y chrony
ln -s /etc/sv/chronyd /var/service/

echo "-------------------------------------------------"
echo "-----         Removing old kernels          -----"
echo "-------------------------------------------------"
touch /etc/cron.monthly/vkpurge
bash -c "echo -e '#!/bin/sh\n\nvkpurge rm all' > /etc/cron.monthly/vkpurge"
chmod u+x /etc/cron.monthly/vkpurge

#echo "-------------------------------------------------"
#echo "-----           Power Management            -----"
#echo "-------------------------------------------------"
#xbps-install -y tlp
#ln -s /etc/sv/tlp /var/service/
#sed -i 's/#SATA_LINKPWR_DENYLIST=.*/SATA_LINKPWR_DENYLIST="host0"/' /etc/tlp.conf
#sed -i 's/#AHCI_RUNTIME_PM_ON_BAT=.*/AHCI_RUNTIME_PM_ON_BAT=on/' /etc/tlp.conf

echo "-------------------------------------------------"
echo "-----           Network,Firewalls           -----"
echo "-------------------------------------------------"
xbps-install -y ufw
ln -s /etc/sv/ufw /var/service/
ufw enable

echo "-------------------------------------------------"
echo "-----             Network,IWD               -----"
echo "-------------------------------------------------"
xbps-install -y iwd
ln -s /etc/sv/dhcpcd /var/service/
ln -s /etc/sv/dbus /var/service/
ln -s /etc/sv/iwd /var/service/
#xbps-install -y broadcom-wl-dkms

echo "-------------------------------------------------"
echo "-----      Session and Seat Management      -----"
echo "-------------------------------------------------"
rm /var/service/acpid
xbps-install -y elogind

echo "-------------------------------------------------"
echo "-----                 Xorg                  -----"
echo "-------------------------------------------------"
xbps-install -y xorg-minimal
cp /etc/X11/xinit/xinitrc /home/$NAME/.xinitrc
sed -i '/&$/d' /home/$NAME/.xinitrc
sed -i '/^exec/d' /home/$NAME/.xinitrc

#echo "-------------------------------------------------"
#echo "-----           Graphics Drivers            -----"
#echo "-------------------------------------------------"
#if AMD
#then
#  xbps-install -y mesa-dri vulkan-loader mesa-vulkan-radeon amdvlk xf86-video-amdgpu xf86-video-ati mesa-vaapi mesa-vdpau
#elif Intel
#then
#  xbps-install -y mesa-dri vulkan-loader mesa-vulkan-intel intel-video-accel
#  # echo "export LIBVA_DRIVER_NAME=i965" >> ~/.xinitrc
#elif NVIDIA
#then
#  xbps-install -y 
#fi

#echo "-------------------------------------------------"
#echo "-----                 Fonts                 -----"
#echo "-------------------------------------------------"

#echo "-------------------------------------------------"
#echo "-----                 Icons                 -----"
#echo "-------------------------------------------------"

echo "-------------------------------------------------"
echo "-----               PipeWire                -----"
echo "-------------------------------------------------"
xbps-install -y pipewire libspa-bluetooth
echo "pipewire &" >> /home/$NAME/.xinitrc
echo "pipewire-pulse &" >> /home/$NAME/.xinitrc

echo "-------------------------------------------------"
echo "-----               Bluetooth               -----"
echo "-------------------------------------------------"
xbps-install -y bluez
touch /etc/sv/bluetoothd/down
ln -s /etc/sv/bluetoothd /var/service/

echo "-------------------------------------------------"
echo "-----                Flatpak                -----"
echo "-------------------------------------------------"
xbps-install -y flatpak
su - $NAME <<BOI
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
BOI

#echo "-------------------------------------------------"
#echo "-----               Printing                -----"
#echo "-------------------------------------------------"


echo "-------------------------------------------------"
echo "-----                libvirt                -----"
echo "-------------------------------------------------"
xbps-install -y libvirt virt-manager #virt-manager-tools
ln -s /etc/sv/libvirtd /var/service/
ln -s /etc/sv/virtlockd /var/service/
ln -s /etc/sv/virtlogd /var/service/

echo "-------------------------------------------------"
echo "-----               xbps-src                -----"
echo "-------------------------------------------------"
xbps-install -y git
su - $NAME <<BOI
	mkdir /home/$NAME/.git-clones
	cd /home/$NAME/.git-clones
	git clone https://github.com/void-linux/void-packages.git
	cd void-packages
	./xbps-src binary-bootstrap
BOI
