#!/bin/bash

# encryptedpw.sh (ver. 1.0 – “solved” version)
#
# A simple FTP‐upload utility that reads an encrypted password from a local file,
# decrypts it with "cruft", and then uses ftp to upload a specified file, echoing
# each intermediate step in tutorial fashion.

# === Exit codes ===
E_BADARGS=85        # Wrong number of arguments

# === Check for correct invocation ===
if [ -z "$1" ]; then
    echo "Usage: $(basename "$0") filename"
    exit $E_BADARGS
fi

echo "DEBUG: Script started. Argument (file to upload): '$1'"

# === User, encrypted‐password file, server settings ===
Username="bozo"    # Change this to your actual FTP username
pword_file="/home/bozo/secret/password_encrypted.file"  
                  # Local file containing the encrypted password :contentReference[oaicite:0]{index=0}
Server="ftp.example.com"
Directory="upload_dir"  # Change to the target directory on the FTP server

echo "DEBUG: Username set to '$Username'"
echo "DEBUG: Encrypted password file: '$pword_file'"
echo "DEBUG: FTP server: '$Server', target directory: '$Directory'"

# === Strip any path from the argument to get just the filename ===
Filename="$(basename "$1")"
echo "DEBUG: Stripped path, will upload file named: '$Filename'"

# === Decrypt the password ===
# For demonstration, we assume 'cruft' is installed and the encrypted file exists.
# 'cruft < "$pword_file"' outputs the decrypted (plaintext) password.
echo -n "DEBUG: Decrypting password from '$pword_file'... "
Password="$(cruft < "$pword_file")"
echo "DONE"
echo "DEBUG: Decrypted password (shown here for tutorial): '$Password'"

# === Build the FTP command stream ===
#
# We’ll echo each line that will be sent to the ftp client,
# so you can see exactly what commands are issued.
echo
echo "DEBUG: Beginning FTP session to '$Server'..."
echo "------------------------------------------------"
echo "ftp -n $Server <<End-Of-Session"
echo "  user $Username $Password"
echo
echo "  binary"
echo "  bell"
echo "  cd $Directory"
echo "  put $Filename"
echo "  bye"
echo "End-Of-Session"
echo "------------------------------------------------"
echo

# === Invoke ftp with a “here‐document” ===
#
# The “-n” flag disables auto-login. The lines between “<<End-Of-Session” and
# “End-Of-Session” are fed to the ftp client as commands.
ftp -n "$Server" <<End-Of-Session
user $Username $Password

binary
bell
cd $Directory
put $Filename
bye
End-Of-Session

# === Summary and exit ===
echo
echo "DEBUG: FTP session completed."
echo "File '$Filename' has been uploaded (or an error was reported above)."
exit 0
 