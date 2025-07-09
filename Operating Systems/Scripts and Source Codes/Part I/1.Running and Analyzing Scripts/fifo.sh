#!/bin/bash

#
# Script by James R. Van Zandt, used with permission.
# Comments added by document author for clarity.
#
# Creates a named pipe at /pipe, tars & gzips key system directories,
# and streams the archive over SSH to a remote host as a daily backup.
#
# Must be run as root (to read all dirs & create /pipe). Adjust
# REMOTE_USER and THERE as needed, and ensure /home/REMOTE_USER/backup exists.

HERE=$(uname -n)                 # local hostname
THERE=bilbo                      # remote backup host
REMOTE_USER=xyz                  # remote login user
PIPE=/pipe

echo "starting remote backup to $THERE at $(date +%r)"

# 1. Prepare the named pipe
rm -f "$PIPE"                    # remove old pipe or file
mkfifo "$PIPE"                   # create fresh named pipe
echo "DEBUG: Created named pipe $PIPE"

# 2. Launch SSH process in background, reading from the pipe
su "$REMOTE_USER" -c \
  "ssh $THERE \"cat > /home/$REMOTE_USER/backup/${HERE}-daily.tar.gz\" < $PIPE" &
echo "DEBUG: Launched background SSH to send data to $THERE"

# 3. Create the compressed archive and write it into the pipe
cd /                             
tar -czf - bin boot dev etc home info lib man root sbin share usr var > "$PIPE"
echo "DEBUG: Archive written to $PIPE"

# 4. Cleanup the named pipe
rm -f "$PIPE"
echo "DEBUG: Removed named pipe $PIPE"

echo "backup to $THERE complete"
exit 0
