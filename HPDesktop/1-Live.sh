#!/usr/bin/env bash

echo "-------------------------------------------------"
echo "-----             Partitioning              -----"
echo "-------------------------------------------------" 
fdisk -l # lists all disks
echo "Please enter disk: (example /dev/sda)"
read DISK # stores the user's input which will be called on by ${DISK}
(
echo g # creates a new empty GPT partition table (clears out any partitions on the drive)
echo n # adds a new partition
echo 1 # sets the new primary partition as the first partition on the drive
echo   # accepts default value for first sector
echo +128M # specifies last sector as 260M from first sector
echo t # changes a partition type
echo 1 # specifies what partition type partition 1 is being changed to (1 = EFI System)
echo n # adds a new partition
echo 2 # sets the new primary partition as the second partition on the drive
echo   # accepts default value for first sector
echo   # accepts default value for last sector
echo w # writes partition table to disk
) | fdisk -W always ${DISK}

echo "-------------------------------------------------"
echo "-----    Encrypted volume configuration     -----"
echo "-------------------------------------------------"
echo "Please create password for the encrypted volume:"
read PASS # stores the user's input which will be called on by ${PASS}
(
echo YES
echo ${PASS}
echo ${PASS}
) | cryptsetup luksFormat --type luks1 ${DISK}2
echo "Please enter a name for the encrypted volume. This will also serve as the hostname:"
read NAME # stores the user's input which will be called on by ${PASS}
(
echo ${PASS}
) | cryptsetup luksOpen ${DISK}2 ${NAME}
vgcreate ${NAME} /dev/mapper/${NAME}
lvcreate --name root -L 10G ${NAME}
lvcreate --name home -l 100%FREE ${NAME}
mkfs.xfs -L root /dev/${NAME}/root
mkfs.xfs -L home /dev/${NAME}/home

echo "-------------------------------------------------"
echo "-----          System installation          -----"
echo "-------------------------------------------------"
mount /dev/${NAME}/root /mnt
for dir in dev proc sys run; do mkdir -p /mnt/$dir ; mount --rbind /$dir /mnt/$dir ; mount --make-rslave /mnt/$dir ; done
mkdir -p /mnt/home
mount /dev/${NAME}/home /mnt/home
mkfs.vfat ${DISK}1
mkdir -p /mnt/boot/efi
mount ${DISK}1 /mnt/boot/efi
(
echo Y
) | xbps-install -Sy -R https://repo-us.voidlinux.org/current/musl -r /mnt base-system cryptsetup grub-x86_64-efi lvm2
curl -O https://raw.githubusercontent.com/GoGoGitter/Void-Linux-Installer/main/HPDesktop/1-LivePart2.sh
mv 1-LivePart2.sh /mnt
chroot /mnt sh ./1-LivePart2.sh
rm /mnt/1-LivePart2.sh
umount -R /mnt

echo "-------------------------------------------------"
echo "-----   You may now shut down the system    -----"
echo "-------------------------------------------------"
