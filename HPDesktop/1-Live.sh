#!/usr/bin/env bash

echo "-------------------------------------------------"
echo "-----              Some Stuff               -----"
echo "-------------------------------------------------" 
touch /etc/xbps.d/settings.conf # making a config file for XBPS
echo "architecture=x86_64-musl" >> /etc/xbps.d/settings.conf
echo "repository=https://repo-us.voidlinux.org/current/musl" >> /etc/xbps.d/settings.conf
echo "ignorepkg=sudo" >> /etc/xbps.d/settings.conf

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
cryptsetup luksFormat --type luks1 ${DISK}2
echo "Please enter a name for the encrypted volume. This will also serve as the hostname:"
read NAME
cryptsetup luksOpen ${DISK}2 ${NAME}
vgcreate ${NAME} /dev/mapper/${NAME}
lvcreate --name root -L 10G ${NAME}
lvcreate --name home -l 100%FREE ${NAME}
mkfs.ext4 -L root /dev/${NAME}/root
mkfs.ext4 -L home /dev/${NAME}/home

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
echo Y # piping the answer to a question about importing keys because the -y flag does not deal with it 
) | SSL_NO_VERIFY_PEER=true xbps-install -Sy -r /mnt base-system cryptsetup grub-x86_64-efi lvm2 doas NetworkManager
curl -k -O https://raw.githubusercontent.com/GoGoGitter/Void-Linux-Installer/main/HPDesktop/1-LivePart2.sh
mv 1-LivePart2.sh /mnt
chroot /mnt /bin/bash ./1-LivePart2.sh
rm /mnt/1-LivePart2.sh
umount -R /mnt

echo "-------------------------------------------------"
echo "-----   You may now shut down the system    -----"
echo "-------------------------------------------------"
