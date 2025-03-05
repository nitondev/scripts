#!/bin/bash

install() {
	echo -e "[niton.dev repo install]\n"
	
    if command -v apt &> /dev/null; then
        update_command="apt update"
        echo "Debian-based system."
    elif command -v yum &> /dev/null; then
        update_command="yum makecache"
        echo "RPM Compatible system."
    elif command -v dnf &> /dev/null; then
        update_command="dnf makecache"
        echo "RPM Compatible system."
    else
        echo "Didn't find supported system."
        exit 1
    fi
    echo -e "\nRun 'sudo $update_command'"
}

remove() {
	echo -e "[niton.dev repo uninstall]\n"
    echo "Repository removed from system."
}

if [ "$1" == "remove" ]; then
    remove
else
    install
fi
