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
echo +260M # specifies last sector as 260M from first sector
echo t # changes a partition type
echo 1 # specifies what partition type partition 1 is being changed to (1 = EFI System)
echo n # adds a new partition
echo 2 # sets the new primary partition as the second partition on the drive
echo   # accepts default value for first sector
echo   # accepts default value for last sector
echo t # changes a partition type
echo 2 # selecting which partition's type will be changed
echo 23 # # specifies what partition type partition 2 is being changed to (23 = Linux x86-64 root)
echo w # writes partition table to disk
) | fdisk ${DISK}
