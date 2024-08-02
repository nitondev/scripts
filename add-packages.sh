#!/bin/bash

# Set the directory variables
PACKAGE_DIR="$HOME/Packages"
REPO_DIR="$HOME/GitHub/archive/apt"

# Create arrays to store package paths and names
declare -a packages

# Add all packages in $PACKAGE_DIR to the array
for package in "$PACKAGE_DIR"/*.deb; do
  packages+=("$package")
done

# Create all necessary directories in $REPO_DIR
mkdir -p "$REPO_DIR/dists/stable/main/binary-amd64"
mkdir -p "$REPO_DIR/dists/stable/main/binary-all"

# Process each package
for package in "${packages[@]}"; do
  package_name=$(basename "$package")

  # Extract the first letter of the package name
  first_letter=$(echo "$package_name" | cut -c 1 | tr '[:upper:]' '[:lower:]')

  # Check if the package name contains architecture info
  if [[ ! "$package_name" =~ _amd64\.deb$ && ! "$package_name" =~ _all\.deb$ ]]; then
    # If not, add _amd64 to the package name
    new_package_name="${package_name%.deb}_amd64.deb"
    mv "$package" "$PACKAGE_DIR/$new_package_name"
    package_name="$new_package_name"
    package="$PACKAGE_DIR/$new_package_name"
  fi

  # Create the corresponding folder based on the first letter
  mkdir -p "$REPO_DIR/pool/main/$first_letter"

  # Move the package to the correct location
  mv "$package" "$REPO_DIR/pool/main/$first_letter/"
done

# Generate Packages and Packages.gz files
cd "$REPO_DIR" || exit

# For amd64 packages
dpkg-scanpackages pool/main /dev/null > dists/stable/main/binary-amd64/Packages
gzip -k -f dists/stable/main/binary-amd64/Packages

# For all architecture packages
dpkg-scanpackages pool/main /dev/null > dists/stable/main/binary-all/Packages
gzip -k -f dists/stable/main/binary-all/Packages

echo "Packages have been added and the repository has been updated."

cd $REPO_DIR
cd ..

git add .
git commit "added packages to repo"
git push
