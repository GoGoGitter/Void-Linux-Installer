#!/usr/bin/env bash

echo "-------------------------------------------------"
echo "-----      Installation Configuration       -----"
echo "-------------------------------------------------"
echo "Please enter a hostname:"
read HOST
echo "${HOST}" > /etc/hostname

echo "-------------------------------------------------"
echo "-----          Set a Root Password          -----"
echo "-------------------------------------------------"
echo "Enter root password:"
read PASS # stores the user's input which will be called on by ${PASS}
echo -e "${PASS}\n${PASS}" | passwd # setting the root password

echo "-------------------------------------------------"
echo "-----            Configure fstab            -----"
echo "-------------------------------------------------"
cp /proc/mounts /etc/fstab

# echo "-------------------------------------------------"
# echo "-----            Installing GRUB            -----"
# echo "-------------------------------------------------"
# xbps-install grub-x86_64-efi
# grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="Void" --removable
# 
# echo "-------------------------------------------------"
# echo "-----             Finalization              -----"
# echo "-------------------------------------------------"
# xbps-reconfigure -fa
