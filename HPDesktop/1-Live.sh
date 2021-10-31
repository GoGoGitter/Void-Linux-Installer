#!/usr/bin/env bash

echo "-------------------------------------------------"
echo "-----              Some Stuff               -----"
echo "-------------------------------------------------" 
touch /etc/xbps.d/settings.conf # making a config file for XBPS
echo "architecture=x86_64-musl" >> /etc/xbps.d/settings.conf # specifies the machine architecture
echo "repository=https://repo-us.voidlinux.org/current/musl" >> /etc/xbps.d/settings.conf # specifies a US mirror to use as a repository
SSL_NO_VERIFY_PEER=true xbps-install -Su # syncing the repositories and updating all installed packages to avoid potential dependency issues later
SSL_NO_VERIFY_PEER=true xbps-install -Su # XBPS must use a separate transaction to update itself. So running this twice will ensure it updates itself and then other packages.

#v   v   v   v   v   v   Install   v   v   v   v   v   v
echo "-------------------------------------------------"
echo "-----             Partitioning              -----"
echo "-------------------------------------------------" 
fdisk -l # lists all disks
echo "Please enter disk: (example /dev/sda)"
read DISK # stores the user's input which will be called on by ${DISK}
( # piping all these would-be-interactive inputs into fdisk
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
) | fdisk -W always ${DISK} # partitioning the specified disk and automatically wiping previously existing filesystem signatures upon writing the new partition table

echo "-------------------------------------------------"
echo "-----    Encrypted volume configuration     -----"
echo "-------------------------------------------------"
cryptsetup luksFormat --type luks1 ${DISK}2 # encrypting partition 2 of the specified disk
echo "Please enter a name for the encrypted volume. This will also serve as the hostname:"
read NAME # stores the user's input which will be called on by ${NAME}
cryptsetup luksOpen ${DISK}2 ${NAME} # unlocking the newly created encrypted volume and naming it
vgcreate ${NAME} /dev/mapper/${NAME} # 
lvcreate --name root -L 10G ${NAME} # "partitioning" the encrypted volume to create a root partition of size 10G
lvcreate --name home -l 100%FREE ${NAME} # "partitioning" the encrypted volume to create a home partition. It will take up the remaining space of the encrypted volume
mkfs.ext4 -L root /dev/${NAME}/root # formatting root partition with Ext4 file system
mkfs.ext4 -L home /dev/${NAME}/home # formatting home partition with Ext4 file system

echo "-------------------------------------------------"
echo "-----          System installation          -----"
echo "-------------------------------------------------"
mount /dev/${NAME}/root /mnt
for dir in dev proc sys run; do mkdir -p /mnt/$dir ; mount --rbind /$dir /mnt/$dir ; mount --make-rslave /mnt/$dir ; done
mkdir -p /mnt/home
mount /dev/${NAME}/home /mnt/home
mkfs.vfat ${DISK}1 # formatting boot partition with FAT32 file system
mkdir -p /mnt/boot/efi
mount ${DISK}1 /mnt/boot/efi
(
echo Y
) | SSL_NO_VERIFY_PEER=true xbps-install -Sy -r /mnt base-system cryptsetup grub-x86_64-efi lvm2
curl -k -O https://raw.githubusercontent.com/GoGoGitter/Void-Linux-Installer/main/HPDesktop/1-LivePart2.sh
mv 1-LivePart2.sh /mnt
chroot /mnt /bin/bash ./1-LivePart2.sh
rm /mnt/1-LivePart2.sh
umount -R /mnt

echo "-------------------------------------------------"
echo "-----   You may now shut down the system    -----"
echo "-------------------------------------------------"
#^   ^   ^   ^   ^   ^   Install   ^   ^   ^   ^   ^   ^
