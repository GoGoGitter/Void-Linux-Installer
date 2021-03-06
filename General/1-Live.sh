#!/usr/bin/env bash

##################################################
######              Variables               ######
##################################################
# This script supports up to two disks, one for root(/) and one for home. If only using one disk, leave DISK2 blank
DISK=
DISK2=
# Valid characters for hostnames and usernames are lowercase letters from a to z,the digits from 0 to 9, and the hyphen (-); the name may not start with a hyphen
HOST=clever-hostname # hostname and name of primary disk's encrypted volume
NAME=cool-username # username of user to be created and put in the wheel group
TIME=Canada/Eastern # timezone. acceptable values are given in /usr/share/zoneinfo. e.g Canada/Eastern

# Uncomment only one of the following
#REPO=https://repo-default.voidlinux.org
#REPO=https://repo-fi.voidlinux.org
#REPO=https://mirrors.servercentral.com/voidlinux
#REPO=https://repo-us.voidlinux.org

echo '-------------------------------------------------'
echo '-----             Partitioning              -----'
echo '-------------------------------------------------'
(
echo g # creates a new empty GPT partition table (clears out any partitions on the drive)
echo n # adds a new partition
echo 1 # sets the new primary partition as the first partition on the drive
echo   # accepts default value for first sector
echo +300M # specifies last sector as 300M from first sector
echo t # changes a partition's type (defaults to selecting partition 1 as it is the only existing one for now)
echo 1 # specifies what partition type partition 1 is being changed to (1 = EFI System)
echo n # adds a new partition
echo 2 # sets the new primary partition as the second partition on the drive
echo   # accepts default value for first sector
echo   # accepts default value for last sector
echo w # writes partition table to disk
) | fdisk -W always $DISK # -W flag automatically wipes previously existing filesystem signatures upon writing the new partition table
if [ "$DISK2" != "" ]
then
  (
  echo g # creates a new empty GPT partition table (clears out any partitions on the drive)
  echo n # adds a new partition
  echo 1 # sets the new primary partition as the first partition on the drive
  echo   # accepts default value for first sector
  echo   # accepts default value for last sector
  echo w # writes partition table to disk
  ) | fdisk -W always $DISK2 # -W flag automatically wipes previously existing filesystem signatures upon writing the new partition table
fi

echo "-------------------------------------------------"
echo "-----    Encrypted volume configuration     -----"
echo "-------------------------------------------------"
BOOT_PART=$(fdisk -l | grep ^$DISK | awk '{print $1}' | awk '{if (NR==1) {print}}')
ROOT_PART=$(fdisk -l | grep ^$DISK | awk '{print $1}' | awk '{if (NR==2) {print}}')
if [ "$DISK2" != "" ]
then
  HOME_PART=$(fdisk -l | grep ^$DISK2 | awk '{print $1}' | awk '{if (NR==1) {print}}')
fi
touch temp-key.txt
cryptsetup luksFormat --type luks1 $ROOT_PART temp-key.txt
cryptsetup luksOpen $ROOT_PART $HOST --key-file temp-key.txt
vgcreate $HOST /dev/mapper/$HOST
if [ "$DISK2" != "" ]
then
  HOST2=${HOST}2
  lvcreate --name root -l 100%FREE $HOST  
  touch temp-key2.txt
  cryptsetup luksFormat --type luks1 $HOME_PART temp-key2.txt
  cryptsetup luksOpen $HOME_PART $HOST2 --key-file temp-key2.txt
  vgcreate $HOST2 /dev/mapper/$HOST2
else
  HOST2=$HOST
  lvcreate --name root -L 50G $HOST
fi
lvcreate --name home -l 100%FREE $HOST2
mkfs.ext4 -L root /dev/$HOST/root
mkfs.ext4 -L home /dev/$HOST2/home

echo "-------------------------------------------------"
echo "-----          System Installation          -----"
echo "-------------------------------------------------"
mount /dev/$HOST/root /mnt
for dir in dev proc sys run; do mkdir -p /mnt/$dir ; mount --rbind /$dir /mnt/$dir ; mount --make-rslave /mnt/$dir ; done
mkdir -p /mnt/home
mount /dev/$HOST2/home /mnt/home
mkfs.vfat $BOOT_PART
mkdir -p /mnt/boot/efi
mount $BOOT_PART /mnt/boot/efi
mkdir -p /etc/xbps.d
touch /etc/xbps.d/ignore_sudo.conf
echo ignorepkg=sudo > /etc/xbps.d/ignore_sudo.conf
mkdir -p /mnt/etc/xbps.d
touch /mnt/etc/xbps.d/ignore_sudo.conf
echo ignorepkg=sudo > /mnt/etc/xbps.d/ignore_sudo.conf
mkdir -p /mnt/var/db/xbps/keys
cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys/
hwclock --systohc
XBPS_ARCH=x86_64 xbps-install -Sy -R $REPO/current -r /mnt base-system cryptsetup grub-x86_64-efi lvm2 vim curl
cp /etc/resolv.conf /mnt/etc/
curl -O https://raw.githubusercontent.com/GoGoGitter/Void-Linux-Installer/main/General/1-LivePart2.sh
mv 1-LivePart2.sh /mnt
mv temp-key.txt /mnt
if [ "$DISK2" != "" ]
then
  mv temp-key2.txt /mnt
fi
DISK=$DISK DISK2=$DISK2 HOST=$HOST HOST2=$HOST2 NAME=$NAME TIME=$TIME BOOT_PART=$BOOT_PART ROOT_PART=$ROOT_PART HOME_PART=$HOME_PART REPO=$REPO chroot /mnt /bin/bash ./1-LivePart2.sh
rm /mnt/1-LivePart2.sh
#umount -R /mnt

echo "-------------------------------------------------"
echo "-----   You may now shut down the system    -----"
echo "-------------------------------------------------"
