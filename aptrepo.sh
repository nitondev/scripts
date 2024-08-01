#!/bin/bash

FG='\033[1;32m'
FC='\033[1;36m'
NC='\033[0m'

# Define repository details
REPO_URL="https://archive.niton.dev/apt"
REPO_FILE="/etc/apt/sources.list.d/nitondev.list"

echo -e "[${FG}+${NC}] adding ${FC}archive.niton.dev${NC} to sources"

# Create the APT repository configuration file
echo "deb [trusted=yes] ${REPO_URL} stable main" | sudo tee ${REPO_FILE} > /dev/null

# Update APT cache
sudo apt-get update

echo -e "[${FG}+${NC}] ${FC}archive.niton.dev${NC} added and cache updated."
