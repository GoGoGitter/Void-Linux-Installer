#!/usr/bin/env bash

echo "-------------------------------------------------"
echo "-----             Partitioning              -----"
echo "-------------------------------------------------" 
fdisk -l
echo "Please enter disk: (example /dev/sda)"
read DISK 
(
echo g # creates a new empty GPT partition table (clears out any partitions on the drive)
echo n # adds a new partition
echo 1 # sets the new primary partition as the first partition on the drive
echo   # accepts default value for first sector
echo +256M # specifies last sector as 260M from first sector
echo t # changes a partition's type (defaults to selecting partition 1 as it is the only existing one for now)
echo 1 # specifies what partition type partition 1 is being changed to (1 = EFI System)
echo n # adds a new partition
echo 2 # sets the new primary partition as the second partition on the drive
echo   # accepts default value for first sector
echo   # accepts default value for last sector
echo w # writes partition table to disk
) | fdisk -W always ${DISK} # -W flag automatically wipes previously existing filesystem signatures upon writing the new partition table

echo "-------------------------------------------------"
echo "-----    Encrypted volume configuration     -----"
echo "-------------------------------------------------"
cryptsetup luksFormat --type luks1 ${DISK}p2
echo "Please enter a name for the encrypted volume. This will also serve as the hostname:"
read HOST
cryptsetup luksOpen ${DISK}p2 ${HOST}
vgcreate ${HOST} /dev/mapper/${HOST}
lvcreate --name root -L 50G ${HOST}
lvcreate --name home -l 100%FREE ${HOST}
mkfs.ext4 -L root /dev/${HOST}/root
mkfs.ext4 -L home /dev/${HOST}/home

echo "-------------------------------------------------"
echo "-----          System installation          -----"
echo "-------------------------------------------------"
mount /dev/${HOST}/root /mnt
for dir in dev proc sys run; do mkdir -p /mnt/$dir ; mount --rbind /$dir /mnt/$dir ; mount --make-rslave /mnt/$dir ; done
mkdir -p /mnt/home
mount /dev/${HOST}/home /mnt/home
mkfs.vfat ${DISK}p1
mkdir -p /mnt/boot/efi
mount ${DISK}p1 /mnt/boot/efi
hwclock --systohc
(
echo Y # piping the answer to a question about importing keys because the -y flag does not deal with it 
) | XBPS_ARCH=x86_64 xbps-install -Sy -R https://repo-us.voidlinux.org/current -r /mnt base-system cryptsetup grub-x86_64-efi lvm2 opendoas iwd vim curl
curl -O https://raw.githubusercontent.com/GoGoGitter/Void-Linux-Installer/main/DellXPS7590/1-LivePart2.sh
mv 1-LivePart2.sh /mnt
DISK=${DISK} HOST=${HOST} chroot /mnt /bin/bash ./1-LivePart2.sh
rm /mnt/1-LivePart2.sh
umount -R /mnt

echo "-------------------------------------------------"
echo "-----   You may now shut down the system    -----"
echo "-------------------------------------------------"
