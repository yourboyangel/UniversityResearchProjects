#!/bin/bash
#
# see.sh – View a file or directory: ls for directories, more for files

if [ $# -ne 1 ]; then
    echo "Usage: $(basename "$0") name"
    exit 1
fi

name=$1

if [ -d "$name" ]; then
    echo "Directory contents of '$name':"
    ls "$name"
elif [ -e "$name" ]; then
    echo "Viewing file '$name':"
    more "$name"
else
    echo "Error: '$name' does not exist."
    exit 2
fi
