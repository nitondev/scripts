#!/bin/bash

# Warning for the user
echo "WARNING: This is a semi-automated script to install Arch Linux."
echo "Using this script improperly may lead to data loss or system corruption."
echo "Please make sure you understand the process before continuing."
echo "Proceeding with this script is at your own risk."

echo
read -p "Enter your username (default: user): " USER_NAME
USER_NAME=${USER_NAME:-user} 
read -p "Enter your hostname (default: archlinux): " HOSTNAME
HOSTNAME=${HOSTNAME:-archlinux}
echo
echo -e "Username is set to '$USER_NAME'\nHostname is set to '$HOSTNAME'"


# Disk to install Arch (change this as necessary)
DISK="/dev/sda"  # Modify if needed

# Step 1: Update system (from Arch ISO)
echo "Updating system..."
pacman -Sy

# Step 2: Partition the disk
echo "Partitioning the disk $DISK..."
(
echo g  # Create GPT partition table
echo n  # Create new partition
echo 1  # Partition number
echo    # Default first sector
echo +512M  # Boot partition size
echo t  # Change partition type
echo 1  # UEFI partition type
echo n  # Create new partition
echo 2  # Partition number
echo    # Default first sector
echo    # Rest of the disk for root partition
echo w  # Write partition table
) | fdisk $DISK

# Step 3: Format partitions
echo "Formatting partitions..."
mkfs.fat -F32 ${DISK}1   # Boot partition
mkfs.ext4 ${DISK}2        # Root partition

# Step 4: Mount partitions
echo "Mounting partitions..."
mount ${DISK}2 /mnt
mkdir /mnt/boot
mount ${DISK}1 /mnt/boot

# Step 5: Install base packages
echo "Installing base packages..."
pacstrap /mnt base linux linux-firmware sudo networkmanager nano

# Step 6: Generate fstab
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Step 7: Chroot into the system
echo "Chrooting into the system..."
arch-chroot /mnt /bin/bash <<EOF

# Step 8: Set hostname
echo "Setting hostname..."
echo "$HOSTNAME" > /etc/hostname
echo "127.0.0.1   localhost" >> /etc/hosts
echo "::1         localhost" >> /etc/hosts
echo "127.0.1.1   $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

# Step 9: Install sudo and add user
echo "Installing sudo and adding user..."
useradd -m -G wheel -s /bin/bash $USER_NAME
echo "$USER_NAME:password" | chpasswd  # Change 'password' to your desired password
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Step 10: Enable NetworkManager
echo "Enabling NetworkManager..."
systemctl enable NetworkManager

# Step 11: Install GRUB bootloader for UEFI
echo "Installing and configuring GRUB..."
pacman -S grub efibootmgr --noconfirm
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch
grub-mkconfig -o /boot/grub/grub.cfg

# Step 12: Exit chroot and finish installation
EOF

# Step 13: Finalize installation and reboot
echo "Finalizing installation and rebooting..."
umount -R /mnt
reboot
