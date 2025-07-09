#!/bin/bash

# copy-cd.sh (ver. 1.1 – “solved” version)
#
# A tutorial‐style utility to copy the entire contents of a data CD/DVD
# device into a local directory, echoing each intermediate step.

# === Exit codes ===
E_BADARGS=85     # Wrong number of args
E_MOUNTFAIL=86   # Mount failed
E_COPYFAIL=87    # Copy failed
E_UMOUNTFAIL=88  # Unmount failed

# === 1. Check arguments ===
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Usage: $(basename "$0") <device> [target-directory]"
    echo "  e.g. $(basename "$0") /dev/cdrom ~/cd_backup"
    exit $E_BADARGS
fi

DEVICE="$1"
TARGET_DIR="${2:-./cd_copy}"

echo "DEBUG: Device to read:    $DEVICE"
echo "DEBUG: Target directory:  $TARGET_DIR"

# === 2. Create a temporary mount point ===
MNT_DIR="$(mktemp -d)"
echo "DEBUG: Created mount point: $MNT_DIR"

# === 3. Ensure target directory exists ===
mkdir -p "$TARGET_DIR"
echo "DEBUG: Ensured target exists: $TARGET_DIR"

# === 4. Mount the CD/DVD device ===
echo "DEBUG: Mounting $DEVICE at $MNT_DIR..."
if mount "$DEVICE" "$MNT_DIR"; then
    echo "  Mounted → $MNT_DIR"
else
    echo "ERROR: Failed to mount $DEVICE"
    exit $E_MOUNTFAIL
fi

# === 5. Copy all files (preserve attributes) ===
echo "DEBUG: Copying from $MNT_DIR → $TARGET_DIR"
if cp -av "$MNT_DIR"/* "$TARGET_DIR"/; then
    echo "  Copy succeeded"
else
    echo "ERROR: Copy failed"
    umount "$MNT_DIR" 2>/dev/null
    exit $E_COPYFAIL
fi

# === 6. Unmount the device ===
echo "DEBUG: Unmounting $MNT_DIR..."
if umount "$MNT_DIR"; then
    echo "  Unmounted"
else
    echo "ERROR: Failed to unmount $MNT_DIR"
    exit $E_UMOUNTFAIL
fi

# === 7. Clean up mount point ===
rmdir "$MNT_DIR"
echo "DEBUG: Removed mount point: $MNT_DIR"

echo "DONE: Contents of $DEVICE are now in $TARGET_DIR"
exit 0
