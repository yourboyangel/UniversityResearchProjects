#!/bin/bash

if test $# -ne 2; then
    echo "Usage: $0 source destination"
    exit 1
fi

source="$1"
dest="$2"

if test ! -f "$source"; then
    echo "Error: Source file '$source' does not exist or is not a regular file."
    exit 1
fi


if test -d "$dest"; then
    dest_file="$dest/$(basename "$source")"
else
    dest_file="$dest"
fi

if test -e "$dest_file"; then
    echo "cpi: overwrite '$dest_file'? (y/n)"
    read response
    if test "$response" != "y" && test "$response" != "Y"; then
        echo "Copy aborted."
        exit 0
    fi
fi

cp "$source" "$dest_file"
if test $? -eq 0; then
    echo "Copied '$source' to '$dest_file'."
else
    echo "Error: Failed to copy '$source' to '$dest_file'."
    exit 1
fi