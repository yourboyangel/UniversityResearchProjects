#!/bin/bash
#
# lsdirs.sh – List only subdirectories in the cwd

for entry in *; do
    [ -d "$entry" ] && echo "$entry"
done
