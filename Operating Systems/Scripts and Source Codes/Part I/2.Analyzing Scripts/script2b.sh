#!/bin/bash
# Define the directory to analyze
DIRNAME=/usr/bin
# Define the file type to filter (string to match in 'file' command output)
FILETYPE="shell script"
# Define the log file to store results
LOGFILE=logfile

# Output initial parameters for clarity
echo "Starting script with parameters:"
echo "DIRNAME=$DIRNAME"
echo "FILETYPE=$FILETYPE"
echo "LOGFILE=$LOGFILE"

# Step 1: Run 'file' command on all files in DIRNAME and output the command being executed
echo "Executing: file $DIRNAME/*"
# Run 'file' command to identify file types
file "$DIRNAME"/* > /tmp/file_output
# Output the number of files processed by 'file'
echo "Number of files processed by 'file': $(wc -l < /tmp/file_output)"

# Step 2: Filter output to include only lines containing FILETYPE
echo "Filtering for lines containing '$FILETYPE'"
fgrep "$FILETYPE" /tmp/file_output > /tmp/grep_output
# Output the number of matching lines
echo "Number of lines matching '$FILETYPE': $(wc -l < /tmp/grep_output)"

# Step 3: Save filtered output to LOGFILE and display it
echo "Saving filtered output to $LOGFILE and displaying"
tee $LOGFILE < /tmp/grep_output > /tmp/tee_output
# Output confirmation that data was written to LOGFILE
echo "Filtered output saved to $LOGFILE"

# Step 4: Count the number of lines (number of matching files)
echo "Counting number of lines (matching files)"
NUM_LINES=$(wc -l < /tmp/tee_output)
# Output the final count
echo "Number of shell scripts found: $NUM_LINES"

# Clean up temporary files
rm -f /tmp/file_output /tmp/grep_output /tmp/tee_output

# Output script termination
echo "Script terminating"
# Exit with success status
exit 0
