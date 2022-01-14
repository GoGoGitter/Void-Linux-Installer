#!/usr/bin/env bash

echo "-------------------------------------------------"
echo "-----      Installation Configuration       -----"
echo "-------------------------------------------------"
echo "Please enter a hostname:"
read HOST
echo ${HOST} > /etc/hostname
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "-------------------------------------------------"
echo "-----          Set a Root Password          -----"
echo "-------------------------------------------------"
echo "Please create new root password:"
read ROOT # stores the user's input which will be called on by ${ROOT}
(
echo ${ROOT}
echo ${ROOT}
) | passwd root

echo "-------------------------------------------------"
echo "-----            Configure fstab            -----"
echo "-------------------------------------------------"
echo "tmpfs /tmp tmpfs defaults,nosuid,nodev 0 0" > /etc/fstab
echo "UUID=$(blkid -o value -s UUID ${DISK}2) / ext4 defaults 0 1" >> /etc/fstab
echo "UUID=$(blkid -o value -s UUID ${DISK}4) /home ext4 defaults 0 2" >> /etc/fstab
echo "UUID=$(blkid -o value -s UUID ${DISK}1) /boot/efi vfat defaults 0 2" >> /etc/fstab
echo "UUID=$(blkid -o value -s UUID ${DISK}3) swap swap defaults 0 0" >> /etc/fstab

echo "-------------------------------------------------"
echo "-----            Installing GRUB            -----"
echo "-------------------------------------------------"
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="Void" --removable

echo "-------------------------------------------------"
echo "-----             Finalization              -----"
echo "-------------------------------------------------"
xbps-reconfigure -fa

echo "-------------------------------------------------"
echo "-----           Users and Groups            -----"
echo "-------------------------------------------------"
echo "Please enter a username:"
read NAME
useradd -m ${NAME}
echo "Please enter a password for this user:"
read PASS
(
echo ${PASS}
echo ${PASS}
) | passwd ${NAME}
gpasswd -a ${NAME} wheel
touch /etc/doas.conf
echo "permit nopass :wheel as root" > /etc/doas.conf

echo "-------------------------------------------------"
echo "-----               Time zone               -----"
echo "-------------------------------------------------"
echo "Enter city:"
read CITY
ln -sf /usr/share/zoneinfo/America/${CITY} /etc/localtime
hwclock --systohc

echo "-------------------------------------------------"
echo "-----               Network                 -----"
echo "-------------------------------------------------"
ln -s /etc/sv/dhcpcd /var/service/
ln -s /etc/sv/dbus /var/service/
ln -s /etc/sv/iwd /var/service/
