#!/bin/bash
# Author: Nathan Coulter
# This code is released to the public domain.
# The author gave permission to use this code snippet in the ABS Guide.

# Output initial setup
echo "Starting script to rename files in current directory"

# Find files in current directory (maxdepth 1, regular files only)
# Use null character (\000) as delimiter for filenames to handle special characters
echo "Executing 'find' to list regular files in current directory"
find -maxdepth 1 -type f -printf '%f\000' | {
    # Output that we're entering the while loop to process files
    echo "Entering while loop to read and rename files"
    
    # Read filenames delimited by null character
    while read -d $'\000'; do
        # Output the current filename being processed
        echo "Processing file: $REPLY"
        
        # Get the file's last modification time using 'stat'
        echo "Executing 'stat -c %y' to get modification time of '$REPLY'"
        MOD_TIME=$(stat -c '%y' "$REPLY")
        # Output the modification time
        echo "Modification time: $MOD_TIME"
        
        # Convert modification time to YYYYMMDDHHMMSS format using 'date'
        echo "Converting modification time to YYYYMMDDHHMMSS format"
        NEW_PREFIX=$(date -d "$MOD_TIME" '+%Y%m%d%H%M%S')
        # Output the new prefix
        echo "New prefix: $NEW_PREFIX"
        
        # Construct new filename by prepending timestamp to original name
        NEW_NAME="$NEW_PREFIX-$REPLY"
        # Output the new filename
        echo "New filename will be: $NEW_NAME"
        
        # Rename the file using 'mv'
        echo "Renaming '$REPLY' to '$NEW_NAME'"
        mv "$REPLY" "$NEW_NAME"
        # Output confirmation of rename
        echo "File renamed successfully"
        
    done
    # Output that the while loop has completed
    echo "Finished processing all files"
}

# Output script termination
echo "Script terminating"

# Exit with success status
exit 0
# Warning: Test-drive this script in a "scratch" directory.
# It will somehow affect all the files there.
