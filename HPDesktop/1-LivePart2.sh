#!/usr/bin/env bash

echo "Enter name of disk (such as /dev/sda) again:"
read DISK

echo "Enter name of encrypted volume again:"
read NAME

chown root:root /
chmod 755 /
echo "Please create new root password:"
read ROOT # stores the user's input which will be called on by ${ROOT}
(
echo ${ROOT}
echo ${ROOT}
) | passwd root
echo ${NAME} > /etc/hostname
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "LC_COLLATE=C" >> /etc/locale.conf

echo "-------------------------------------------------"
echo "-----       Filesystem configuration        -----"
echo "-------------------------------------------------"
echo "tmpfs /tmp tmpfs defaults,nosuid,nodev 0 0" > /etc/fstab
UUID=$(blkid -o value -s UUID /dev/${NAME}/root)
echo "UUID=${UUID} / ext4 defaults 0 1" >> /etc/fstab
UUID=$(blkid -o value -s UUID /dev/${NAME}/home)
echo "UUID=${UUID} /home ext4 defaults 0 2" >> /etc/fstab
UUID=$(blkid -o value -s UUID ${DISK}1)
echo "UUID=${UUID} /boot/efi vfat defaults 0 2" >> /etc/fstab

echo "-------------------------------------------------"
echo "-----          GRUB configuration           -----"
echo "-------------------------------------------------"
echo "GRUB_ENABLE_CRYPTODISK=y" >> /etc/default/grub
UUID=$(blkid -o value -s UUID ${DISK}2)
sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT='rd.lvm.vg=$NAME rd.luks.uuid=$UUID'/" /etc/default/grub

echo "-------------------------------------------------"
echo "-----            LUKS key setup             -----"
echo "-------------------------------------------------"
dd bs=1 count=64 if=/dev/urandom of=/boot/volume.key
cryptsetup luksAddKey ${DISK}2 /boot/volume.key
chmod 000 /boot/volume.key
chmod -R g-rwx,o-rwx /boot
echo "${NAME}   ${DISK}2   /boot/volume.key   luks" >> /etc/crypttab
echo 'install_items+=" /boot/volume.key /etc/crypttab "' > /etc/dracut.conf.d/10-crypt.conf

echo "-------------------------------------------------"
echo "-----     Complete system installation      -----"
echo "-------------------------------------------------"
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="Void" --removable
xbps-reconfigure -fa
