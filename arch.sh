#!/usr/bin/env bash

set -e

BOOT_SIZE="1GiB"
SWAP_SIZE="2GiB"
ROOT_SIZE="100%"
TIMEZONE=$(curl -s http://ip-api.com/json | sed -n 's/.*"timezone":"\([^"]*\)".*/\1/p')

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

parted -s "$DISK" mkpart primary linux-swap $BOOT_SIZE $((BOOT_SIZE+SWAP_SIZE))

parted -s "$DISK" mkpart primary ext4 $((BOOT_SIZE+SWAP_SIZE)) 100%


echo -e "\n-------- Disk Formatting --------"