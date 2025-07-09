#!/bin/bash

# tree2.sh (ver. 1.0 – tutorial‐style directory size tree with debug)
#
# Builds a size‐based directory tree using du, with extensive debug
# echoes showing each stage: building the inventory, filtering entries,
# and recursion decisions.
# Script by Patsie; reformatted and annotated for clarity.

# --- Configuration ---
TOP=5            # Show top 5 largest entries per level
MAXRECURS=5      # Max recursion depth
E_DIR=81         # Missing or bad directory argument
SELF=$(basename "$0")
PID=$$
TMP="/tmp/${SELF}.${PID}.tmp"

# --- Function: dot (format numbers with commas) ---
dot() {
  echo " $*" | sed -e :a -e 's/\(.*[0-9]\)\([0-9]\{3\}\)/\1,\2/;ta' | tail -c 12
}

# --- Function: tree ---
# Usage: tree <depth> <prefix> <minsize> <directory>
tree() {
  local depth=$1 prefix=$2 minsize=$3 dirname=$4
  echo "DEBUG: tree() called: depth=$depth, prefix='$prefix', minsize=$minsize, dir='$dirname'"

  # Filter the du output for entries under $dirname larger than $minsize
  LIST=$(egrep "[[:space:]]${dirname}/[^/]*\$" "$TMP" \
    | awk '{ if($1 > '"$minsize"') print }' \
    | sort -nr \
    | head -n $TOP)

  echo "DEBUG: Raw list for '$dirname':"
  echo "$LIST"
  [ -z "$LIST" ] && { echo "DEBUG: No entries > $minsize under '$dirname', returning"; return; }

  local cnt=0 num=$(echo "$LIST" | wc -l)
  echo "DEBUG: Found $num entries under '$dirname' (showing top $TOP)"

  # Process each entry
  echo "$LIST" | while read size name; do
    cnt=$((cnt+1))
    local bname=$(basename "$name")
    [ -d "$name" ] && bname+="/"
    echo "DEBUG: Entry $cnt/$num: size=$size, name='$name', bname='$bname'"
    echo "$(dot $size)$prefix +-$bname"

    # Recurse if this is a directory and we haven't hit MAXRECURS
    if [ -d "$name" ] && [ $depth -lt $MAXRECURS ]; then
      if [ $cnt -lt $num ]; then
        next_prefix="${prefix}|"
      else
        next_prefix="${prefix} "
      fi
      echo "DEBUG: Recursing into '$name' with depth=$((depth+1)), prefix='$next_prefix'"
      tree $((depth+1)) "$next_prefix" $((size/10)) "$name"
    fi
  done

  echo "DEBUG: Returning from tree(depth $depth) with blank line"
  echo
}

# --- Main Program ---
if [ $# -ne 1 ]; then
  echo "Usage: $SELF <directory>" >&2
  exit $E_DIR
fi

rootdir=$1
if [ ! -d "$rootdir" ]; then
  echo "ERROR: '$rootdir' is not a directory" >&2
  exit $E_DIR
fi

echo "DEBUG: Building inventory list for '$rootdir', please wait..."
du -akx "$rootdir" > "$TMP"
size=$(tail -1 "$TMP" | awk '{print $1}')

# Print root entry
echo "$(dot $size) $rootdir"

echo "DEBUG: Starting tree at root"
tree 0 "" 0 "$rootdir"

# Cleanup
rm -f "$TMP"
echo "DEBUG: Removed temporary file '$TMP'"

exit 0
