#!/bin/bash
# Script to track changes to the system log file /var/log/messages

# Output initial setup
echo "Starting script to track changes in /var/log/messages"

# Check if /var/log/messages exists
echo "Checking if /var/log/messages exists"
if [ ! -f /var/log/messages ]; then
    echo "Error: /var/log/messages does not exist or is not a file"
    exit 1
fi
echo "/var/log/messages found, proceeding"

# Start tail -f to monitor /var/log/messages and pipe output to while loop
echo "Executing 'tail -f /var/log/messages' to monitor log file"
tail -f /var/log/messages | {
    # Output that we're entering the while loop
    echo "Entering while loop to read log lines"
    
    # Read each line from the pipe
    while read LINE; do
        # Output that a new line has been read
        echo "Read new log line"
        # Output the content of the line
        echo "Log line content: $LINE"
        # Echo the line to stdout (original functionality)
        echo "$LINE"
    done
    # Output that the while loop has ended (though it won't due to tail -f)
    echo "While loop ended (unexpected, as tail -f runs indefinitely)"
}

# Output script termination (unreachable due to tail -f)
echo "Script terminating"
exit 0
