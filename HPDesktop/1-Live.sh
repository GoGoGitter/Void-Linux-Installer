#!/usr/bin/env bash

echo "-------------------------------------------------"
echo "-----         Prepare Filesystems           -----"
echo "-------------------------------------------------" 
fdisk -l # lists all disks
echo "Please enter disk: (example /dev/sda)"
read DISK # stores the user's input which will be called on by ${DISK}
(
echo g # creates a new empty GPT partition table (clears out any partitions on the drive)
echo n # adds a new partition
echo 1 # sets the new primary partition as the first partition on the drive
echo   # accepts default value for first sector
echo +256M # specifies last sector as 256M from first sector
echo t # changes a partition type
echo 1 # specifies what partition type partition 1 is being changed to (1 = EFI System)
echo n # adds a new partition
echo 2 # sets the new primary partition as the second partition on the drive
echo   # accepts default value for first sector
echo   # accepts default value for last sector
echo w # writes partition table to disk
) | fdisk -W always ${DISK}
mkfs.fat -F 32 "${DISK}1" # formatting boot partition with FAT32 file system
mkfs.ext4 "${DISK}2" # formatting root partition with Ext4 file system

echo "-------------------------------------------------"
echo "-----Create a New Root and Mount Filesystems-----"
echo "-------------------------------------------------"
mount "${DISK}2" /mnt/
mkdir -p /mnt/boot/efi/
mount "${DISK}1" /mnt/boot/efi/

echo "-------------------------------------------------"
echo "-----           Base Installation           -----"
echo "-------------------------------------------------"
(
echo Y
) | XBPS_ARCH=x86_64-musl xbps-install -Sy -r /mnt -R https://repo-us.voidlinux.org/current/musl base-system

echo "-------------------------------------------------"
echo "-----          Entering the Chroot          -----"
echo "-------------------------------------------------"
mount --rbind /sys /mnt/sys && mount --make-rslave /mnt/sys
mount --rbind /dev /mnt/dev && mount --make-rslave /mnt/dev
mount --rbind /proc /mnt/proc && mount --make-rslave /mnt/proc
cp /etc/resolv.conf /mnt/etc/
curl -O https://raw.githubusercontent.com/GoGoGitter/Void-Linux-Installer/main/HPDesktop/1-LivePart2.sh
mv 1-LivePart2.sh /mnt
PS1='(chroot) # ' chroot /mnt/ /bin/bash ./1-LivePart2.sh
rm /mnt/1-LivePart2.sh
# umount -R /mnt

echo "-------------------------------------------------"
echo "-----   You may now shut down the system    -----"
echo "-------------------------------------------------"
