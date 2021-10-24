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
) | fdisk ${DISK}


echo "-------------------------------------------------"
echo "-----    Encrypted volume configuration     -----"
echo "-------------------------------------------------"
echo "Please create password for the encrypted volume:"
read PASS # stores the user's input which will be called on by ${PASS}
(
echo YES
echo ${PASS}
echo ${PASS}
) | cryptsetup luksFormat --type luks1 /dev/sda2
(
echo ${PASS}
) | cryptsetup luksOpen /dev/sda2 devoid
