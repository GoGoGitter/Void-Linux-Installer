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
) | cryptsetup luksFormat --type luks1 /dev/sda2
echo "Please enter a name for the encrypted volume. This will also serve as the hostname:"
read NAME # stores the user's input which will be called on by ${PASS}
(
echo ${PASS}
) | cryptsetup luksOpen /dev/sda2 ${NAME}
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
mkfs.vfat /dev/sda1
mkdir -p /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi
xbps-install -Sy -R https://repo-us.voidlinux.org/current/musl -r /mnt base-system cryptsetup grub-x86_64-efi lvm2
chroot /mnt
chown root:root /
chmod 755 /
echo "Please create new root password:"
read ROOT # stores the user's input which will be called on by ${ROOT}
echo -e "${ROOT}\n${ROOT}" | passwd root # setting the root password
echo ${NAME} > /etc/hostname
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "LC_COLLATE=C" >> /etc/locale.conf

echo "-------------------------------------------------"
echo "-----       Filesystem configuration        -----"
echo "-------------------------------------------------"
echo "/dev/${NAME}/root  /         ext4     defaults              0       0" >> /etc/fstab
echo "/dev/${NAME}/home  /home     ext4     defaults              0       0" >> /etc/fstab
echo "/dev/sda1         /boot/efi vfat     defaults              0       0" >> /etc/fstab

echo "-------------------------------------------------"
echo "-----          GRUB configuration           -----"
echo "-------------------------------------------------"
echo "GRUB_ENABLE_CRYPTODISK=y" >> /etc/default/grub
blkid -o value -s UUID /dev/sda2
read UUID
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=rd.lvm.vg=${NAME} rd.luks.uuid=${UUID}/' /etc/default/grub

echo "-------------------------------------------------"
echo "-----            LUKS key setup             -----"
echo "-------------------------------------------------"
dd bs=1 count=64 if=/dev/urandom of=/boot/volume.key
(
echo ${PASS} 
) | cryptsetup luksAddKey /dev/sda2 /boot/volume.key
chmod 000 /boot/volume.key
chmod -R g-rwx,o-rwx /boot
echo "${NAME}   /dev/sda2   /boot/volume.key   luks" >> /etc/crypttab
echo 'install_items+=" /boot/volume.key /etc/crypttab "' > /etc/dracut.conf.d/10-crypt.conf

echo "-------------------------------------------------"
echo "-----     Complete system installation      -----"
echo "-------------------------------------------------"
grub-install /dev/sda
xbps-reconfigure -fa
exit 
umount -R /mnt
shutdown now
