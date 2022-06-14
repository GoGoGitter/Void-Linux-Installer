#!/usr/bin/env bash

chown root:root /
chmod 755 /
echo $HOST > /etc/hostname
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/default/libc-locales
xbps-reconfigure -f glibc-locales

echo "-------------------------------------------------"
echo "-----       Filesystem configuration        -----"
echo "-------------------------------------------------"
echo "tmpfs /tmp tmpfs defaults,nosuid,nodev 0 0" > /etc/fstab
echo "UUID=$(blkid -o value -s UUID /dev/$HOST/root) / ext4 defaults 0 1" >> /etc/fstab
echo "UUID=$(blkid -o value -s UUID /dev/$HOST2/home) /home ext4 defaults 0 2" >> /etc/fstab
echo "UUID=$(blkid -o value -s UUID $BOOT_PART) /boot/efi vfat defaults 0 2" >> /etc/fstab

echo "-------------------------------------------------"
echo "-----          GRUB configuration           -----"
echo "-------------------------------------------------"
echo "GRUB_ENABLE_CRYPTODISK=y" >> /etc/default/grub
if [ "$(lsblk --discard | grep "${DISK:5} " | grep 0B)" = "" ]
then
  sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT='rd.lvm.vg=$HOST rd.luks.uuid=$(blkid -o value -s UUID $ROOT_PART) rd.luks.allow-discards'/" /etc/default/grub
else
  sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT='rd.lvm.vg=$HOST rd.luks.uuid=$(blkid -o value -s UUID $ROOT_PART)'/" /etc/default/grub
fi

echo "-------------------------------------------------"
echo "-----            LUKS key setup             -----"
echo "-------------------------------------------------"
dd bs=1 count=64 if=/dev/urandom of=/boot/root-volume.key
cryptsetup luksAddKey $ROOT_PART /boot/root-volume.key --key-file temp-key.txt
chmod 000 /boot/root-volume.key
chmod -R g-rwx,o-rwx /boot
echo "$HOST   UUID=$(blkid -o value -s UUID $ROOT_PART)   /boot/root-volume.key   luks" >> /etc/crypttab
if [ "$DISK2" != "" ]
then
  mkdir /etc/cryptsetup-keys.d
  dd bs=1 count=64 if=/dev/urandom of=/etc/cryptsetup-keys.d/home-volume.key
  cryptsetup luksAddKey $HOME_PART /etc/cryptsetup-keys.d/home-volume.key --key-file temp-key2.txt
  chmod 000 /etc/cryptsetup-keys.d/home-volume.key
  if [ "$(lsblk --discard | grep "${DISK2:5} " | grep 0B)" = "" ]
  then
    echo "$HOST2   UUID=$(blkid -o value -s UUID $HOME_PART)   /etc/cryptsetup-keys.d/home-volume.key   luks,discard" >> /etc/crypttab
  else
    echo "$HOST2   UUID=$(blkid -o value -s UUID $HOME_PART)   /etc/cryptsetup-keys.d/home-volume.key   luks" >> /etc/crypttab
  fi
  echo 'install_items+=" /boot/root-volume.key /etc/cryptsetup-keys.d/home-volume.key /etc/crypttab "' > /etc/dracut.conf.d/10-crypt.conf
else
  echo 'install_items+=" /boot/root-volume.key /etc/crypttab "' > /etc/dracut.conf.d/10-crypt.conf
fi

echo "-------------------------------------------------"
echo "-----     Complete system installation      -----"
echo "-------------------------------------------------"
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="Void" --removable
xbps-reconfigure -fa

#echo "-------------------------------------------------"
#echo "-----                Network                -----"
#echo "-------------------------------------------------"
#ln -s /etc/sv/dhcpcd /var/service/
#ln -s /etc/sv/dbus /var/service/
#ln -s /etc/sv/iwd /var/service/

echo "-------------------------------------------------"
echo "-----               Passwords               -----"
echo "-------------------------------------------------"
echo "Set a new root password:"
passwd root

echo "Set password for primary encrypted volume"
cryptsetup luksChangeKey $ROOT_PART --key-file temp-key.txt
rm temp-key.txt

if [ "$DISK2" != "" ]
then
  echo "Set password for secondary encrypted volume"
  cryptsetup luksChangeKey $HOME_PART --key-file temp-key2.txt
  rm temp-key2.txt
fi

echo "Set a password for $NAME:"
passwd $NAME

echo "-------------------------------------------------"
echo "-----         System Configuration          -----"
echo "-------------------------------------------------"
curl -O https://raw.githubusercontent.com/GoGoGitter/Void-Linux-Installer/main/General/2-Configuration.sh
DISK=$DISK DISK2=$DISK2 HOST=$HOST HOST2=$HOST2 NAME=$NAME TIME=$TIME BOOT_PART=$BOOT_PART ROOT_PART=$ROOT_PART HOME_PART=$HOME_PART REPO=$REPO /bin/bash 2-Configuration.sh
rm 2-Configuration.sh
