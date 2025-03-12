#!/usr/env bash

set -e

echo -e "
-------- Updating system --------
"
sleep 1
#pacman -Syu

echo -e "
-------- Disk Formating --------
"
lsblk

echo -e "\nSelect disk to format (eg /dev/sda)"
read -r -p "> " DISK_SELECT </dev/tty

echo
echo "Disk '$DISK_SELECT' selected for formating."

echo -e  "\nWarning: This will erase all data on the selected disk!\nThis action cannot be undone."
read -r -p "Do you want to continue? (y/N): " USER_INPUT </dev/tty
USER_INPUT=${USER_INPUT:-n} 

while [[ ! "$USER_INPUT" =~ ^[YyNn]$ ]]; do
    echo "Invalid input."
    read -r -p "Do you want to continue? (y/N): " USER_INPUT </dev/tty
    USER_INPUT=${USER_INPUT:-n}
done

#!/usr/env bash

set -e

echo -e "
-------- Updating system --------
"
sleep 1
#pacman -Syu

echo -e "
-------- Disk Formating --------
"
lsblk

echo -e "\nSelect disk to format (eg /dev/sda)"
read -p "> " DISK_SELECT

echo
echo "Disk '$DISK_SELECT' selected for formating."

echo -e  "\nWarning: This will erase all data on the selected disk!\nThis action cannot be undone."
read -p "Do you want to continue? (y/N): " USER_INPUT
USER_INPUT=${USER_INPUT:-n} 

while [[ ! "$USER_INPUT" =~ ^[YyNn]$ ]]; do
    echo "Invalid input."
    read -p "Do you want to continue? (y/N): " USER_INPUT
    USER_INPUT=${USER_INPUT:-n}
done

format_disk() {
	echo -e "
	-------- Wiping Disk --------
	"
	echo "Wiping disk and creating new GPT partition table."
	parted --script "$DISK_SELECT" mklabel gpt
	echo "Creating EFI System Partition (512MB)..."
	parted --script "$DISK_SELECT" mkpart ESP fat32 1MiB 513MiB
	parted --script "$DISK_SELECT" set 1 esp on
	echo "Creating Swap Partition (2GB)..."
	parted --script "$DISK_SELECT" mkpart primary linux-swap 513MiB 2561MiB
	echo "Creating Root Partition (remaining space)..."
	parted --script "$DISK_SELECT" mkpart primary ext4 2561MiB 100%

	echo "Formatting partitions..."
	mkfs.fat -F32 "${DISK_SELECT}1"
	mkswap "${DISK_SELECT}2"
	mkfs.ext4 "${DISK_SELECT}3"

	echo "Mounting partitions..."
	mount "${DISK_SELECT}3" /mnt
	mkdir -p /mnt/boot
	mount "${DISK_SELECT}1" /mnt/boot
	swapon "${DISK_SELECT}2"
	
	echo "Partitioning and formatting completed."
}




if [[ "$USER_INPUT" =~ ^[Yy]$ ]]; then
    format_disk
else
    echo -e "\nAborting installation script.."
    exit 1
fi





if [[ "$USER_INPUT" =~ ^[Yy]$ ]]; then
    format_disk
else
    echo -e "\nAborting installation script.."
    exit 1
fi
