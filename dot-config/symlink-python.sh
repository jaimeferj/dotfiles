#!/bin/bash
# Define the source and destination directories
src="nvim"
dst="nvim-python"

src=$(realpath "$src")
dst=$(realpath "$dst")

# Create the destination directory if it doesn't exist
mkdir -p "$dst"

# Change to the source directory for relative paths
cd "$src" || exit

# Use find to locate only files (not directories), excluding any path containing '/languages/'
find . \( -path "*/languages" -o -path "*/languages/*" \) -prune -o -type f -print | while read -r item; do
    # Compute the full source path and the corresponding destination path
    target="$src/$item"
    linkpath="$dst/$item"

    # Create the necessary destination subdirectory
    mkdir -p "$(dirname "$linkpath")"

    # Create the symbolic link for the file
    ln -s "$target" "$linkpath"
done
