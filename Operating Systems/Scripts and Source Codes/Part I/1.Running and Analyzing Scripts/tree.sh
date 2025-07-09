#!/bin/bash

#
# Displays a directory-tree of a given directory (or the current one),
# printing “+---dirname” for each subdirectory and indenting with “| ”
# per level.  Shows debug lines for each step so you can trace how the
# tree is built and how recursion proceeds.

# Exit codes
E_USAGE=85

usage() {
  echo "Usage: $(basename "$0") [directory]"
  exit $E_USAGE
}

# --- search FUNCTION ---
# $1 = current depth (0 for top), $2… = parent directories (unused here)
search() {
  local depth=$1
  shift
  echo "DEBUG: search() called at level $depth in $(pwd)"
  # Loop over all entries in this directory
  for entry in *; do
    echo "DEBUG: Checking entry '$entry'"
    if [ -d "$entry" ]; then
      # Print indent markers
      local i
      indent=""
      for ((i=0; i<depth; i++)); do
        indent+="| "
      done
      # Distinguish symlink vs real dir
      if [ -L "$entry" ]; then
        echo "${indent}+---$entry [symlink -> $(readlink "$entry")]"
      else
        echo "${indent}+---$entry"
        (( numdirs++ ))
        echo "DEBUG: Descending into '$entry'"
        cd "$entry" || { echo "ERROR: Cannot cd into '$entry'"; exit 1; }
        search $((depth+1))
        echo "DEBUG: Returning to $(pwd)/.."
        cd ..
      fi
    fi
  done
}

# --- Main ---
# Handle optional directory argument
if [ $# -gt 1 ]; then
  usage
elif [ $# -eq 1 ]; then
  [ -d "$1" ] || { echo "ERROR: '$1' not a directory"; exit 1; }
  cd "$1"
fi

echo "Initial directory = $(pwd)"
numdirs=0
echo "DEBUG: Starting search at level 0"
search 0
echo "Total directories = $numdirs"
exit 0
