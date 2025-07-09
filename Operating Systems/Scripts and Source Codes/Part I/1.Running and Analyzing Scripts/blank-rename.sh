#!/bin/bash

# blank-rename.sh (ver. 1.0 – “solved” version)
#
# A very simple-minded utility that renames every filename containing
# a blank (space) by substituting underscores (“_”) in place of blanks.
# In tutorial fashion, this version echoes each step, including which
# filenames contain spaces, what the new name will be, and whether
# the actual `mv` succeeded.

# === Constants and exit codes ===
ONE=1           # For singular/plural grammar in final report
number=0        # Counter: how many files have actually been renamed
FOUND=0         # Return code from `grep -q “ ”` indicates a space was found
E_USAGE=90      # (Not strictly necessary here, but reserved in case)

# === Debug: Starting announcement ===
echo "DEBUG: Starting blank-rename.sh"
echo "DEBUG: Scanning current directory for filenames containing spaces"
echo

# === Loop through every entry in the current directory ===
for filename in *; do
    # If the glob (*) doesn’t match anything, it literally yields "*"
    if [ "$filename" = "*" ]; then
        echo "DEBUG: No files found in current directory. Exiting."
        break
    fi

    # Show which filename we are examining now
    echo "Checking filename: '$filename'"

    # Step 1: Detect whether the filename contains at least one space
    # We pipe the filename into grep -q " " to check for spaces; grep -q
    # returns FOUND (0) if a match is found, or nonzero if no match.
    echo -n "  → Testing for spaces... "
    echo "$filename" | grep -q " "
    if [ $? -eq $FOUND ]; then
        echo "YES (space detected)"

        # Step 2: Build the new name by substituting all spaces with underscores
        # Use sed 's/ /_/g' to replace every “ ” with “_”
        echo -n "  → Replacing spaces with underscores... "
        newname="$(echo "$filename" | sed -e "s/ /_/g")"
        echo "will become '$newname'"

        # Step 3: Attempt to rename (mv). Wrap in quotes because filenames can contain spaces
        echo "  → Attempting: mv \"$filename\" \"$newname\""
        if mv "$filename" "$newname"; then
            echo "    SUCCESS: '$filename' → '$newname'"
            # Record this rename in our summary
            if [ -z "$renamed_files" ]; then
                renamed_files="$filename -> $newname"
            else
                renamed_files="$renamed_files\n$filename -> $newname"
            fi
            number=$(( number + 1 ))
        else
            echo "    ERROR: Could not rename '$filename' → '$newname'"
        fi

    else
        echo "NO (no space)"
    fi

    echo "  ----"
done

# === Final summary of results ===
echo
if [ "$number" -eq "$ONE" ]; then
    echo "$number file renamed."
else
    echo "$number files renamed."
fi

echo
echo "=================="
echo "Final Renamed Files"
echo "=================="
if [ -n "$renamed_files" ]; then
    # Use printf to interpret "\n" as newlines in the summary string
    printf "%b\n" "$renamed_files"
else
    echo "No files were renamed."
fi

exit 0
