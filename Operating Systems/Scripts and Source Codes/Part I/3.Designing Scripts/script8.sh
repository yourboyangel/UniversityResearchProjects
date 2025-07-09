#!/bin/bash

if test $# -ne 1; then
    echo "Usage: $0 uid"
    exit 1
fi

uid="$1"

if ! test "$uid" -ge 0 2>/dev/null; then
    echo "Error: UID '$uid' must be a non-negative integer."
    exit 1
fi

user_info=$(awk -F: -v uid="$uid" '$3 == uid {print $1 ":" $4 ":" $6 ":" $7}' /etc/passwd)

if test -z "$user_info"; then
    echo "Error: No user found with UID '$uid'."
    exit 1
fi

username=$(echo "$user_info" | cut -d: -f1)
gid=$(echo "$user_info" | cut -d: -f2)
home_dir=$(echo "$user_info" | cut -d: -f3)
shell=$(echo "$user_info" | cut -d: -f4)

group_name=$(awk -F: -v gid="$gid" '$3 == gid {print $1}' /etc/group)

if test -z "$group_name"; then
    group_name="Unknown (GID $gid)"
fi

all_groups=$(groups "$username" 2>/dev/null | cut -d: -f2- | awk '{$1=$1};1')

if test -z "$all_groups"; then
    all_groups="None"
fi

echo "Username: $username"
echo "UID: $uid"
echo "Primary Group ID: $gid"
echo "Primary Group Name: $group_name"
echo "Home Directory: $home_dir"
echo "Shell: $shell"
echo "All Groups: $all_groups"
