#!/bin/bash

# rn.sh (ver. 1.0 – “solved” version)
#
# A simple-minded file renaming utility.  It replaces every occurrence
# of an “old pattern” in each filename with a “new pattern,” and shows
#—in tutorial fashion—each intermediate step.

# === Constants for error handling ===
ARGS=2             # Expect exactly two arguments
E_BADARGS=85       # Exit code if wrong number of args
ONE=1
E_RENAME_FAIL=86   # Exit code if a rename fails

# === Check for correct number of arguments ===
if [ $# -ne "$ARGS" ]; then
    echo "Usage: $(basename "$0") old-pattern new-pattern"
    echo " (e.g., ./rn.sh gif jpg — renames all files containing 'gif' to use 'jpg')"
    exit $E_BADARGS
fi

# === Debug: Show input patterns ===
echo "DEBUG: Old pattern: '$1'"
echo "DEBUG: New pattern: '$2'"

# === Initialize variables ===
number=0             # Counter for how many files have been renamed
renamed_files=""     # Will accumulate lines like "old_name -> new_name"

# === Process matching files ===
echo "DEBUG: Starting file processing for pattern '*$1*'"
echo

for filename in *"$1"*; do
    # If no files match, the literal '*pattern*' stays unexpanded; guard against that
    if [ ! -e "$filename" ] || [ "$filename" = "*$1*" ]; then
        break
    fi

    # Only consider regular files (skip directories, sockets, etc.)
    if [ -f "$filename" ]; then
        echo "Original filename: '$filename'"

        # Step 1: Strip off any path (basename), though here filenames are already in the current directory
        fname="$(basename "$filename")"
        echo "  After stripping path (basename): '$fname'"

        # Step 2: Substitute new pattern for old in the basename
        n="$(echo "$fname" | sed -e "s/$1/$2/")"
        echo "  After substituting '$1' → '$2': '$n'"

        # Step 3: Attempt to rename
        echo "  Attempting to rename '$fname' → '$n' ..."
        if mv "$fname" "$n" 2>/dev/null; then
            echo "    Successfully renamed '$fname' → '$n'"
            # Append this rename to our summary list
            if [ -z "$renamed_files" ]; then
                renamed_files="$fname -> $n"
            else
                renamed_files="$renamed_files\n$fname -> $n"
            fi
            number=$(( number + 1 ))
        else
            echo "    ERROR: Failed to rename '$fname' → '$n'"
            # (We continue processing others even if this one fails.)
        fi

        echo "  ----"
    fi
done

# === Report number of files renamed ===
echo
if [ "$number" -eq "$ONE" ]; then
    echo "$number file renamed."
else
    echo "$number files renamed."
fi

# === Final Summary of all renames ===
echo
echo "=================="
echo "Final Renamed Files"
echo "=================="
if [ -n "$renamed_files" ]; then
    # Use printf so that '\n' sequences become real newlines
    printf "%b\n" "$renamed_files"
else
    echo "No files were renamed."
fi

# Exit cleanly
exit 0
