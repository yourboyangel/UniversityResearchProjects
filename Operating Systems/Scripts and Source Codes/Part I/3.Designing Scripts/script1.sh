#!/bin/bash
#
# rename-f77.sh – Rename *.f77 → *.f90 in the current directory

for filename in *.f77; do
    # If no .f77 files exist, the glob stays literal; skip in that case
    [ -e "$filename" ] || continue

    # Strip off the .f77 suffix
    base=$(basename "$filename" .f77)
    # Move to new name with .f90 appended
    mv -- "$filename" "$base.f90"
    echo "Renamed '$filename' → '$base.f90'"
done
