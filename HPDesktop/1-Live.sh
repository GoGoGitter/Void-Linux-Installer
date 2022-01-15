#!/usr/bin/env bash

echo "-------------------------------------------------"
echo "-----          Prepare Filesystems          -----"
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
echo +10G # specifies last sector as 10G from first sector
echo n # adds a new partition
echo 3 # sets the new primary partition as the second partition on the drive
echo   # accepts default value for first sector
echo +8G # specifies last sector as 8G from first sector
echo n # adds a new partition
echo 4 # sets the new primary partition as the fourth partition on the drive
echo   # accepts default value for first sector
echo   # accepts default value for last sector
echo w # writes partition table to disk
) | fdisk -W always ${DISK} # -W flag automatically wipes previously existing filesystem signatures upon writing the new partition table
mkfs.vfat ${DISK}1
mkfs.ext4 ${DISK}2
mkfs.ext4 ${DISK}4

echo "-------------------------------------------------"
echo "-----Create a New Root and Mount Filesystems-----"
echo "-------------------------------------------------"
mount ${DISK}2 /mnt/
mkdir -p /mnt/boot/efi/
mount ${DISK}1 /mnt/boot/efi/
mkdir -p /mnt/home/
mount ${DISK}4 /mnt/home/
mkswap ${DISK}3

echo "-------------------------------------------------"
echo "-----           Base installation           -----"
echo "-------------------------------------------------"
hwclock --systohc
(
echo Y # piping the answer to a question about importing keys because the -y flag does not deal with it 
) | XBPS_ARCH=x86_64 xbps-install -Sy -R https://repo-us.voidlinux.org/current -r /mnt base-system grub-x86_64-efi opendoas iwd vim curl

echo "-------------------------------------------------"
echo "-----          Entering the Chroot          -----"
echo "-------------------------------------------------"
mount --rbind /sys /mnt/sys && mount --make-rslave /mnt/sys
mount --rbind /dev /mnt/dev && mount --make-rslave /mnt/dev
mount --rbind /proc /mnt/proc && mount --make-rslave /mnt/proc
curl -O https://raw.githubusercontent.com/GoGoGitter/Void-Linux-Installer/main/HPDesktop/1-LivePart2.sh
mv 1-LivePart2.sh /mnt
DISK=${DISK} chroot /mnt /bin/bash ./1-LivePart2.sh
rm /mnt/1-LivePart2.sh
umount -R /mnt

echo "-------------------------------------------------"
echo "-----   You may now shut down the system    -----"
echo "-------------------------------------------------"
