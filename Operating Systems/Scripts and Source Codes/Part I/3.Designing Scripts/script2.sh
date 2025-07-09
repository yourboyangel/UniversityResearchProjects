#!/bin/bash
#
# args.sh – Show how many arguments were passed, with correct singular/plural

count=$#

if [ "$count" -eq 0 ]; then
    # No output at all if no args
    exit 0
elif [ "$count" -eq 1 ]; then
    echo "There is 1 argument:"
    echo "  $1"
else
    echo "There are $count arguments:"
    for arg in "$@"; do
        echo "  $arg"
    done
fi
