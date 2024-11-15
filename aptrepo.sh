#!/bin/bash

set -e

REPO_URL="https://archive.niton.dev/apt"
KEY_URL="https://archive.niton.dev/apt/key.gpg"
DISTRO="stable"
COMPONENT="main"

echo "Connected to $REPO_URL"
echo "[ + ] adding nitonsr.list"

echo "deb $REPO_URL $DISTRO $COMPONENT" | sudo tee /etc/apt/sources.list.d/niton.list > /dev/null

echo "[ + ] downloading key.gpg"

curl -fsSL $KEY_URL | sudo tee /etc/apt/trusted.gpg.d/niton-archive.asc > /dev/null

echo "[ + ] key.gpg installed"

echo "[ + ] updating apt cache"
sudo apt-get update -y > /dev/null

echo -e "\n[ + ] installation complete."