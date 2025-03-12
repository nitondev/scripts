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
	echo "Hello world"	
}




if [[ "$USER_INPUT" =~ ^[Yy]$ ]]; then
    format_disk
else
    echo -e "\nAborting installation script.."
    exit 1
fi
