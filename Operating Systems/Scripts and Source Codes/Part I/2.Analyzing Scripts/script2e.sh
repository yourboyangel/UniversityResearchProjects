#!/bin/bash
# Script to count total lines in all *.java files in src directory and subdirectories

# Output initial setup
echo "Starting script to count lines in *.java files"

# Initialize SUM to 0 and export it
echo "Initializing SUM to 0"
export SUM=0
# Output initial SUM value
echo "Initial SUM: $SUM"

# Find all *.java files in src directory and subdirectories
echo "Executing 'find src -name \"*.java\"' to locate Java files"
# Loop through each file found
for f in $(find src -name "*.java"); do
    # Output the current file being processed
    echo "Processing file: $f"
    
    # Count lines in the file using wc -l and extract the count with awk
    echo "Counting lines in $f with 'wc -l | awk \"{ print \$1 }\"'"
    LINE_COUNT=$(wc -l "$f" | awk '{ print $1 }')
    # Output the line count for this file
    echo "Line count for $f: $LINE_COUNT"
    
    # Update SUM using double-parentheses arithmetic
    echo "Updating SUM: SUM = $SUM + $LINE_COUNT"
    export SUM=$(($SUM + $LINE_COUNT))
    # Output the new SUM value
    echo "New SUM: $SUM"
done

# Output the final total line count
echo "Total lines in all *.java files: $SUM"

exit 0
