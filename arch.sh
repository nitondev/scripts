#!/usr/bin/env bash

set -e

convert_to_miB() {
    echo $(( $(echo "$1" | sed 's/[A-Za-z]*//g') * 1024 ))
}

BOOT_SIZE="1GiB"
SWAP_SIZE="2GiB"
ROOT_SIZE="100%"

TIMEZONE=$(curl -s http://ip-api.com/json | sed -n 's/.*"timezone":"\([^"]*\)".*/\1/p')

# Convert sizes to MiB
BOOT_SIZE_MI=$(( $(convert_to_miB "$BOOT_SIZE") ))
SWAP_SIZE_MI=$(( $(convert_to_miB "$SWAP_SIZE") ))

# Check if we fetched a valid timezone
if [[ -z "$TIMEZONE" ]]; then
    echo "Warning: Could not fetch timezone, defaulting to UTC."
    TIMEZONE="UTC"
fi

echo "-------- Disk Partition --------"

# List available disks
lsblk

echo -e "\nSelect disk to format (e.g., /dev/sda)"
read -r -p "> " DISK </dev/tty

# Validate disk existence
if [[ ! -b "$DISK" ]]; then
    echo -e "\nError: $DISK does not exist!"
    exit 1
fi

# Confirm user choice before proceeding
echo -e "\nYou have selected $DISK."
read -rp "Are you sure? (y/N): " CONFIRM </dev/tty
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "\nAborting operation."
    exit 0
fi

echo -e "\nStarting partitioning of $DISK..."

parted -s "$DISK" mklabel gpt

parted -s "$DISK" mkpart primary ext4 1MiB $BOOT_SIZE

parted -s "$DISK" mkpart primary linux-swap $BOOT_SIZE_MI"MiB" $((BOOT_SIZE_MI + SWAP_SIZE_MI))"MiB"

parted -s "$DISK" mkpart primary ext4 $((BOOT_SIZE_MI + SWAP_SIZE_MI))"MiB" 100%


echo -e "\n-------- Disk Formatting --------"

mkfs.fat -F 32 "$DISK"1
mkfs.ext4 "$DISK"3
mkswap "$DISK"2

mount "$DISK"3 /mnt
mkdir -p /mnt/boot/efi
mount "$DISK"1 /mnt/boot/efi

swapon "$DISK"2

echo -e "\n-------- Base Package Install --------"
sleep 2
pacstrap /mnt base linux linux-firmware nano networkmanager grub efibootmgr

genfstab -U /mnt >> /mnt/etc/fstab