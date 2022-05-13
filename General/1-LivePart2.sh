#!/usr/bin/env bash

chown root:root /
chmod 755 /
echo ${HOST} > /etc/hostname
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/default/libc-locales
xbps-reconfigure -f glibc-locales

echo "-------------------------------------------------"
echo "-----       Filesystem configuration        -----"
echo "-------------------------------------------------"
echo "tmpfs /tmp tmpfs defaults,nosuid,nodev 0 0" > /etc/fstab
echo "UUID=$(blkid -o value -s UUID /dev/${HOST}/root) / ext4 defaults 0 1" >> /etc/fstab
echo "UUID=$(blkid -o value -s UUID /dev/${HOST2}/home) /home ext4 defaults 0 2" >> /etc/fstab
echo "UUID=$(blkid -o value -s UUID ${BOOT_PART}) /boot/efi vfat defaults 0 2" >> /etc/fstab

echo "-------------------------------------------------"
echo "-----          GRUB configuration           -----"
echo "-------------------------------------------------"
echo "GRUB_ENABLE_CRYPTODISK=y" >> /etc/default/grub
UUID=$(blkid -o value -s UUID ${ROOT_PART})
if [ "$DISK_NUM" = "1" ]
then
  sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT='rd.lvm.vg=$HOST rd.luks.uuid=$UUID'/" /etc/default/grub
elif [ "$DISK_NUM" = "2" ]
then
  UUID2=$(blkid -o value -s UUID ${HOME_PART})
  sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT='rd.lvm.vg=$HOST rd.luks.uuid=$UUID rd.lvm.vg=$HOST2 rd.luks.uuid=$UUID2'/" /etc/default/grub
fi

echo "-------------------------------------------------"
echo "-----            LUKS key setup             -----"
echo "-------------------------------------------------"
dd bs=1 count=64 if=/dev/urandom of=/boot/volume.key
cryptsetup luksAddKey ${ROOT_PART} /boot/volume.key --key-file temp-key.txt
chmod 000 /boot/volume.key
echo "${HOST}   ${ROOT_PART}   /boot/volume.key   luks" >> /etc/crypttab
if [ "$DISK_NUM" = "1" ]
then
  echo 'install_items+=" /boot/volume.key /etc/crypttab "' > /etc/dracut.conf.d/10-crypt.conf
elif [ "$DISK_NUM" = "2" ]
then
  dd bs=1 count=64 if=/dev/urandom of=/boot/volume2.key
  cryptsetup luksAddKey ${HOME_PART} /boot/volume2.key --key-file temp-key2.txt
  chmod 000 /boot/volume2.key
  echo "${HOST2}   ${HOME_PART}   /boot/volume2.key   luks" >> /etc/crypttab
  echo 'install_items+=" /boot/volume.key /boot/volume2.key /etc/crypttab "' > /etc/dracut.conf.d/10-crypt.conf
fi
chmod -R g-rwx,o-rwx /boot

echo "-------------------------------------------------"
echo "-----     Complete system installation      -----"
echo "-------------------------------------------------"
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="Void" --removable
xbps-reconfigure -fa

echo "-------------------------------------------------"
echo "-----           Users and Groups            -----"
echo "-------------------------------------------------"
useradd -m ${NAME}
gpasswd -a ${NAME} wheel
touch /etc/doas.conf
echo "permit nopass :wheel as root" > /etc/doas.conf

echo "-------------------------------------------------"
echo "-----               Time zone               -----"
echo "-------------------------------------------------"
ln -sf /usr/share/zoneinfo/${TIME} /etc/localtime
hwclock --systohc

echo "-------------------------------------------------"
echo "-----                Network                -----"
echo "-------------------------------------------------"
ln -s /etc/sv/dhcpcd /var/service/
ln -s /etc/sv/dbus /var/service/
ln -s /etc/sv/iwd /var/service/

echo "-------------------------------------------------"
echo "-----               Passwords               -----"
echo "-------------------------------------------------"
echo "Set a new root password:"
passwd root

echo "Set password for primary encrypted volume"
cryptsetup luksChangeKey ${ROOT_PART} --key-file temp-key.txt
rm temp-key.txt

if [ "$DISK_NUM" = "2" ]
then
  echo "Set password for secondary encrypted volume"
  cryptsetup luksChangeKey ${HOME_PART} --key-file temp-key2.txt
  rm temp-key2.txt
fi

echo "Set a password for ${NAME}:"
passwd ${NAME}