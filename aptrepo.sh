#!/bin/bash

# Define repository details
REPO_URL="https://archive.niton.dev/apt"
REPO_FILE="/etc/apt/sources.list.d/nitondev.list"

# Create the APT repository configuration file
echo "deb [trusted=yes] ${REPO_URL} stable main" | sudo tee ${REPO_FILE} > /dev/null

# Update APT cache
sudo apt-get update

echo "APT repository added and cache updated."
