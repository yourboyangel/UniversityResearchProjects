#!/bin/bash
# Script to track changes to the system log file /var/log/syslog

# Output initial setup
echo "Starting script to track changes in /var/log/syslog"

# Check if /var/log/syslog exists
echo "Checking if /var/log/syslog exists"
if [ ! -f /var/log/syslog ]; then
    echo "Error: /var/log/syslog does not exist or is not a file"
    exit 1
fi
echo "/var/log/syslog found, proceeding"

# Start tail -f to monitor /var/log/syslog and pipe output to while loop
echo "Executing 'tail -f /var/log/syslog' to monitor log file"
tail -f /var/log/syslog | {
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