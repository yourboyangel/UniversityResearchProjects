#!/bin/bash
# mail-format.sh (ver. 1.2): Format e-mail messages.
# Purpose: Removes leading carets (>), tabs, spaces, and folds long lines to a specified width.
# Usage: ./mail-format.sh filename
# Combines debug tracing of each step with a final clean output section.

# === Constants for error handling ===
ARGS=1
E_BADARGS=85
E_NOFILE=86

# === Check for correct number of arguments ===
if [ $# -ne $ARGS ]; then
    echo "Usage: `basename $0` filename"
    exit $E_BADARGS
fi

# === Debug: Show the input filename ===
echo "DEBUG: Input filename is '$1'"

# === Check if the input file exists ===
if [ ! -f "$1" ]; then
    echo "File \"$1\" does not exist."
    exit $E_NOFILE
fi

file_name="$1"
MAXWIDTH=70
echo "DEBUG: File '$file_name' exists and will be processed"
echo "DEBUG: Maximum line width set to $MAXWIDTH characters"

# === Sed commands for step-by-step ===
sed_cmd1='s/^>//'
sed_cmd2='s/^ *>//'
sed_cmd3='s/^ *//'
sed_cmd4='s/^\t*//'

# === Initialize variable to store final results ===
final_results=""

# === Begin processing ===
echo "DEBUG: Starting file processing for '$file_name'"
echo

while IFS= read -r line; do
    echo "OOriginal: '$line'"

    # Step 1: Remove single leading caret
    step1=$(echo "$line" | sed "$sed_cmd1")
    echo "AAfter removing single caret: '$step1'"

    # Step 2: Remove caret(s) with space(s)
    step2=$(echo "$step1" | sed "$sed_cmd2")
    echo "AAfter removing caret(s) with space(s): '$step2'"

    # Step 3: Remove leading spaces
    step3=$(echo "$step2" | sed "$sed_cmd3")
    echo "AAfter removing leading spaces: '$step3'"

    # Step 4: Remove leading tabs
    step4=$(echo "$step3" | sed "$sed_cmd4")
    echo "AAfter removing leading tabs: '$step4'"

    # Fold final cleaned line
    final=$(echo "$step4" | fold -s --width=$MAXWIDTH)
    echo "Fixed (after folding):"
    echo "$final"

    # Append to final_results
    if [ -n "$final" ]; then
        final_results="${final_results}${final}\n"
    fi

    echo "----"
done < "$file_name"

echo "DEBUG: File processing complete"

# === Final Result ===
echo
echo "=================="
echo "Final Clean Output"
echo "=================="
printf "%b" "$final_results"

# Exit cleanly
exit 0