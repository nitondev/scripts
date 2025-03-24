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
    echo "Error: $DISK does not exist!"
    exit 1
fi

# Confirm user choice before proceeding
echo "You have selected $DISK. Proceeding with partitioning and formatting..."
read -rp "Are you sure? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborting operation."
    exit 0
fi

echo "Starting partitioning of $DISK..."

