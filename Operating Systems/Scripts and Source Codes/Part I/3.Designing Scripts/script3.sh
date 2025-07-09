#!/bin/bash
#
# Count how many times a user is logged on

if [ $# -ne 1 ]; then
    echo "Usage: $(basename "$0") username"
    exit 1
fi

user=$1
# who | awk …   or: who | grep -w "$user" | wc -l
count=$(who | awk -v u="$user" '$1==u{c++} END{print c+0}')
echo "$user is logged on $count time(s)."
