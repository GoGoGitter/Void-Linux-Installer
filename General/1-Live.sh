#!/usr/bin/env bash

##################################################
######             Partitioning             ######
################################################## 
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
