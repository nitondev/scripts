#!/usr/bin/env bash

set -e

echo -e "
-------- Disk Formatting --------
"
lsblk || { echo "Failed to list block devices."; exit 1; }

echo -e "\nSelect disk to format (e.g., /dev/sda)"
read -r -p "> " DISK_SELECT </dev/tty

echo
echo "Disk '$DISK_SELECT' selected for formatting."

echo -e "\nWarning: This will erase all data on the selected disk!"
echo "This action cannot be undone."

read -r -p "Do you want to continue? (y/N): " USER_INPUT </dev/tty
USER_INPUT=${USER_INPUT:-n} 

while [[ ! "$USER_INPUT" =~ ^[YyNn]$ ]]; do
    echo "Invalid input."
    read -r -p "Do you want to continue? (y/N): " USER_INPUT </dev/tty
    USER_INPUT=${USER_INPUT:-n}
done

format_disk() {

	echo -e "
	-------- Wiping Disk --------
	"
    parted --script "$DISK_SELECT" mklabel gpt || { echo "Failed to create partition table."; exit 1; }

	echo -e "
	-------- Creating EFI  --------
	"
    parted --script "$DISK_SELECT" mkpart ESP fat32 1MiB 513MiB
    parted --script "$DISK_SELECT" set 1 esp on

    echo -e "
    -------- Creating Swap --------
    "
    parted --script "$DISK_SELECT" mkpart primary linux-swap 513MiB 2561MiB

    echo -e "
    -------- Root Partition --------
    "
    parted --script "$DISK_SELECT" mkpart primary ext4 2561MiB 100%

    echo -e "
    -------- Formating Partition --------
    "
    mkfs.fat -F32 "${DISK_SELECT}1"
    mkswap "${DISK_SELECT}2"
    mkfs.ext4 "${DISK_SELECT}3"

    echo -e "
    -------- Mounting Partitions --------
    "
    mount "${DISK_SELECT}3" /mnt
    mkdir -p /mnt/boot
    mount "${DISK_SELECT}1" /mnt/boot
    swapon "${DISK_SELECT}2"

    echo -e "\nPartitioning and formatting completed."
}


if [[ "$USER_INPUT" =~ ^[Yy]$ ]]; then
    format_disk
else
    echo -e "\nAborting installation script.."
    exit 1
fi

echo -e "
	-------- Installing Base Packages --------
"
pacstrap /mnt base linux linux-firmware vim networkmanager

echo -e "
	-------- Generating fstab --------
"

genfstab -U /mnt >> /mnt/etc/fstab
